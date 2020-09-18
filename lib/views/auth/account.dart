import 'dart:async';

import 'package:camp/views/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class UserData {
  String username;
  String displayName;
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

  void _submitForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();

      print(data.phone);
      SnackBar snackbar = SnackBar(
        content:
            Text('Welcome to Campusel, your account is saved successfully'),
      );
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 4), () {
        Navigator.pop(context, data);
      });
    }
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
                    'Create Your Account',
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
                            autovalidate: true,
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
                            autovalidate: true,
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
                            validator: (val) {
                              if (val.trim().length < 3 || val.isEmpty) {
                                return 'Username is too short';
                              } else if (val.trim().length > 40) {
                                return 'Username is too long';
                              } else {
                                return null;
                              }
                            },
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
                            autovalidate: true,
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
                        FlatButton(
                            color: kYellow,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            onPressed: () => _submitForm(),
                            textColor: Colors.white,
                            child: Center(child: Text('Next')))
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
}
