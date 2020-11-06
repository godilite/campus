import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/models/user_account.dart';
import 'package:camp/service_locator.dart';
import 'package:camp/services/AuthService.dart';
import 'package:camp/views/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camp/helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  final UserAccount user;
  EditProfile({this.user});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController locationController;
  AuthService _authService = locator<AuthService>();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String profileUrl;
  String coverPhoto;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SnackBar usernameSnack = SnackBar(
    content: Text('Profile Updated'),
  );

  @override
  void initState() {
    locationController = TextEditingController();
    locationController.text = widget.user.address;
    _setProfile();
    super.initState();
  }

  _setProfile() async {
    final SharedPreferences prefs = await _prefs;
    coverPhoto = prefs.getString('coverPhoto');
  }

  var data = {};

  void _submitForm() async {
    final form = _formKey.currentState;
    _getLocation();
    if (form.validate()) {
      form.save();
      _authService.updateUserToBackup(data);
    }
    _scaffoldKey.currentState.showSnackBar(usernameSnack);
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
      data['coord'] = GeoPoint(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return CustomScrollView(slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  child: profileStack(viewportConstraints),
                  height: viewportConstraints.maxHeight * 0.3,
                  width: viewportConstraints.maxWidth,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextFormField(
                            cursorColor: kYellow,
                            initialValue: widget.user.name,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                suffixIcon: Icon(
                                  CupertinoIcons.pencil,
                                  color: kYellow,
                                ),
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey),
                                hintText: 'Name',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                )),
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                            onSaved: (val) => data['displayName'] = val,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            cursorColor: kYellow,
                            initialValue: widget.user.email,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                suffixIcon: Icon(
                                  CupertinoIcons.pencil,
                                  color: kYellow,
                                ),
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey),
                                hintText: 'Email Address',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                )),
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Email address is required';
                              }
                              return null;
                            },
                            onSaved: (val) => data['email'] = val,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            cursorColor: kYellow,
                            initialValue: widget.user.phone,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                suffixIcon: Icon(
                                  CupertinoIcons.pencil,
                                  color: kYellow,
                                ),
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey),
                                hintText: 'Phone Number',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                )),
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Phone Number is required';
                              }
                              return null;
                            },
                            onSaved: (val) => data['phone'] = val,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: locationController,
                            cursorColor: kYellow,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                suffixIcon: Icon(
                                  CupertinoIcons.pencil,
                                  color: kYellow,
                                ),
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey),
                                hintText: 'Address',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                )),
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Address is required';
                              }
                              return null;
                            },
                            onSaved: (val) => data['address'] = val,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            cursorColor: kYellow,
                            initialValue: widget.user.username,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                suffixIcon: Icon(
                                  CupertinoIcons.pencil,
                                  color: kYellow,
                                ),
                                filled: true,
                                hintStyle: TextStyle(color: Colors.grey),
                                hintText: 'Username',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                )),
                            validator: (val) {
                              if (val.isEmpty) {
                                return 'Username is required';
                              }
                              return null;
                            },
                            onSaved: (val) => data['username'] = val,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          FlatButton(
                            color: kYellow,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            onPressed: () => _submitForm(),
                            textColor: Colors.white,
                            child: Center(
                              child: Text(
                                'Save',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ],
                      )),
                )
              ]),
            ),
          ]);
        },
      ),
    );
  }

  Stack profileStack(BoxConstraints viewportConstraints) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: coverPhoto != null
                    ? CachedNetworkImageProvider(coverPhoto)
                    : AssetImage('assets/img_not_available.jpeg'),
                fit: BoxFit.cover,
              ),
              color: kYellow,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTapDown: storePosition,
            onTap: () {
              pictureMenu(context).then(
                (value) => setState(() {
                  _setProfile();
                  _scaffoldKey.currentState.showSnackBar(usernameSnack);
                }),
              );
            },
            child: CircleAvatar(
              minRadius: 30,
              backgroundColor: Colors.black12,
              child: Icon(
                Icons.camera_enhance,
                color: kYellow,
              ),
            ),
          ),
        )
      ],
    );
  }
}
