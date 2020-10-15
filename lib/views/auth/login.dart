import 'dart:async';

import 'package:camp/service_locator.dart';
import 'package:camp/services/AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camp/views/auth/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../styles.dart';

class UserData {
  String email;
  String password;
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var authService = locator<AuthService>();
  TextEditingController _c;
  final _formKey = GlobalKey<FormState>();
  @override
  initState() {
    _c = TextEditingController();
    super.initState();
  }

  var data = new UserData();

  Future _addPassword(FirebaseAuthException error) async {
    var password = await showDialog(
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(hintText: "Enter your password"),
                controller: _c,
              ),
              FlatButton(
                child: Text("Continue"),
                onPressed: () {
                  Navigator.pop(context, _c.text);
                },
              )
            ],
          ),
        ),
        context: context);
    return await authService.linkWithPassword(
        error.email, password, error.credential);
  }

  void _signInWithFacebook() async {
    var result = await authService.signInWithFacebook();
    FirebaseAuthException error =
        result.runtimeType.toString() == 'UserAccount' ? null : result['error'];
    if (error != null) {
      switch (result['method']) {
        case 'google.com':
          await authService.linkWithGoogle(error.credential);
          break;
        case 'password':
          await _addPassword(error);
          break;
        default:
      }
      switch (result['error'].code) {
        case 'auth/user-disabled':
          SnackBar snackbar = SnackBar(
            content: Text('Your account is disabled'),
          );
          _scaffoldKey.currentState.showSnackBar(snackbar);
          break;
        case 'auth/user-not-found':
          SnackBar snackbar = SnackBar(
            content: Text('No user corresponding to this email'),
          );
          _scaffoldKey.currentState.showSnackBar(snackbar);
          break;
      }
    }
  }

  void _signInWithGoogle() async {
    var result = await authService.signInWithGoogle();
    FirebaseAuthException error =
        result.runtimeType.toString() == 'UserCredential'
            ? null
            : result['error'];
    if (error != null) {
      switch (result['method']) {
        case 'facebook.com':
          await authService.linkWithFacebook(error.credential);
          break;
        case 'password':
          await _addPassword(error);
          break;
        default:
      }
      switch (result['error'].code) {
        case 'user-disabled':
          SnackBar snackbar = SnackBar(
            content: Text('Your account is disabled'),
          );
          _scaffoldKey.currentState.showSnackBar(snackbar);
          break;
        case 'user-not-found':
          SnackBar snackbar = SnackBar(
            content: Text('No user corresponding to this email'),
          );
          _scaffoldKey.currentState.showSnackBar(snackbar);
          break;
      }
    }
  }

  Future<bool> _signInWithEmail() async {
    var result =
        await authService.signInWithEmailAndPassword(data.email, data.password);

    FirebaseAuthException error =
        result.runtimeType.toString() == 'UserAccount' ? null : result['error'];
    if (error != null) {
      switch (result['method']) {
        case 'google.com':
          await authService.linkWithGoogle(error.credential);
          break;
        case 'facebook.com':
          await authService.linkWithFacebook(error.credential);
          break;
      }

      switch (result['error'].code) {
        case 'wrong-password':
          SnackBar snackbar = SnackBar(
            backgroundColor: kYellow,
            content: Text('Wrong password'),
          );
          _scaffoldKey.currentState.showSnackBar(snackbar);
          return false;

          break;
        case 'invalid-email':
          SnackBar snackbar = SnackBar(
            backgroundColor: kYellow,
            content: Text('Email is invalid'),
          );
          _scaffoldKey.currentState.showSnackBar(snackbar);
          return false;

          break;
        case 'user-disabled':
          SnackBar snackbar = SnackBar(
            backgroundColor: kYellow,
            content: Text('Your account is disabled'),
          );
          _scaffoldKey.currentState.showSnackBar(snackbar);
          return false;

          break;
        case 'user-not-found':
          SnackBar snackbar = SnackBar(
            backgroundColor: kYellow,
            content: Text('No user corresponding to this email'),
          );
          _scaffoldKey.currentState.showSnackBar(snackbar);
          return false;
          break;
      }
    }
    return true;
  }

  void _submitForm() async {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      if (await _signInWithEmail()) {
        SnackBar snackbar = SnackBar(
          content: Text('Signing In...'),
        );
        _scaffoldKey.currentState.showSnackBar(snackbar);
        Timer(Duration(seconds: 4), () {
          Navigator.pop(context, data);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                height: 70,
              ),
              Text(
                'Login',
                style: TextStyle(
                    color: kYellow, fontSize: 25, fontWeight: FontWeight.w600),
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              FlutterIcons.account_box_outline_mco,
                              color: kYellow,
                            ),
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
                        onSaved: (val) => data.email = val,
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: true,
                        decoration: InputDecoration(
                            prefixIcon: Icon(
                              FlutterIcons.account_circle_mdi,
                              color: kYellow,
                            ),
                            hintStyle: TextStyle(color: Colors.grey),
                            hintText: 'Password',
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            )),
                        onSaved: (val) => data.password = val,
                        validator: (val) {
                          if (val.isEmpty) {
                            return 'Password is required';
                          }
                          if (val.length < 7) {
                            return 'Password should be greater than 6';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(color: kYellow),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
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
                          'Signin',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
              TextDivider(),
              SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () => _signInWithFacebook(),
                child: Image.asset('assets/facebook.png'),
              ),
              SizedBox(
                height: 15,
              ),
              TextDivider(),
              SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () => _signInWithGoogle(),
                child: Image.asset('assets/google.png'),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Dont have an account yet?',
                    style: TextStyle(color: kText),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RegisterPage())),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: kYellow),
                    ),
                  )
                ],
              )
            ]),
          ),
        );
      }),
    );
  }
}

class TextDivider extends StatelessWidget {
  const TextDivider({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('Or'),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
