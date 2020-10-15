import 'dart:async';

import 'package:camp/service_locator.dart';
import 'package:camp/services/AuthService.dart';
import 'package:camp/views/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class UserData {
  String username;
  String displayName;
  String address;
  GeoPoint coord;
  var phone;
}

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  UserData data = new UserData();
  TextEditingController locationController;
  AuthService _authService = locator<AuthService>();
  @override
  void initState() {
    locationController = TextEditingController();
    _getLocation();
    super.initState();
  }

  void _submitForm() async {
    final form = _formKey.currentState;
    if (!await _authService.checkifUsernameExist(data.username)) {
      SnackBar usernameSnack = SnackBar(
        content: Text('Username already exist'),
      );
      _scaffoldKey.currentState.showSnackBar(usernameSnack);

      return;
    }

    if (form.validate()) {
      form.save();
      SnackBar snackbar = SnackBar(
        backgroundColor: kYellow,
        content:
            Text('Welcome to Campusel, your account is saved successfully'),
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 4), () {
        Navigator.pop(context, data);
      });
    }
  }

  ///Gets the current location
  _getLocation() async {
    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) await requestPermission();

    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    //  String address =
    //      '${place.subThoroughfare} ${place.thoroughfare}, ${place.subLocality} ${place.locality}, ${place.subAdministrativeArea} ${place.administrativeArea}, ${place.country}';
    String specificAddress = '${place.locality}, ${place.country}';
    setState(() {
      locationController.text = specificAddress;
      data.coord = GeoPoint(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return ListView(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 90),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Complete Your Account',
                    style: TextStyle(
                        color: kYellow,
                        fontSize: 25,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 15,
                                    spreadRadius: 4)
                              ]),
                          child: TextFormField(
                            cursorColor: kYellow,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  FlutterIcons.account_box_outline_mco,
                                  color: kYellow,
                                ),
                                hintStyle: TextStyle(color: Colors.grey),
                                hintText: 'Display Name',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                )),
                            validator: (val) {
                              if (val.trim().length < 3 || val.isEmpty) {
                                return 'Display Name is too short';
                              } else if (val.trim().length > 40) {
                                return 'Display Name is too long';
                              } else {
                                return null;
                              }
                            },
                            onSaved: (val) => data.displayName = val,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 15,
                                    spreadRadius: 4)
                              ]),
                          child: TextFormField(
                            cursorColor: kYellow,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  FlutterIcons.account_circle_mdi,
                                  color: kYellow,
                                ),
                                hintStyle: TextStyle(color: Colors.grey),
                                hintText: 'Choose a username',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                )),
                            validator: validateUsername,
                            onSaved: (val) => data.username = val,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 15,
                                    spreadRadius: 4)
                              ]),
                          child: TextFormField(
                            cursorColor: kYellow,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: validateMobile,
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  FlutterIcons.phone_ant,
                                  color: kYellow,
                                ),
                                hintStyle: TextStyle(color: Colors.grey),
                                hintText: 'Phone Number',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                )),
                            onSaved: (val) => data.phone = val,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 15,
                                    spreadRadius: 4)
                              ]),
                          child: TextFormField(
                            controller: locationController,
                            cursorColor: kYellow,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: validateLocation,
                            decoration: InputDecoration(
                                prefixIcon: Icon(
                                  FlutterIcons.map_check_mco,
                                  color: kYellow,
                                ),
                                hintStyle: TextStyle(color: Colors.grey),
                                hintText: 'Location',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                )),
                            onSaved: (val) =>
                                data.address = locationController.text,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        FlatButton(
                          color: kYellow,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          onPressed: () => _submitForm(),
                          textColor: Colors.white,
                          child: Center(
                            child: Text('Next'),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  String validateMobile(String value) {
    String patttern = r'(^(?:[+234])?[0-9]{11,13}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

  String validateUsername(String value) {
    if (value.trim().length < 3 || value.isEmpty) {
      return 'Username is too short';
    } else if (value.trim().length > 40) {
      return 'Username is too long';
    } else {
      return null;
    }
  }

  String validateLocation(String value) {
    if (value.trim().length < 3 || value.isEmpty) {
      return 'Address is required';
    }
    return null;
  }
}
