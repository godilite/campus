import 'package:camp/service_locator.dart';
import 'package:camp/services/AuthService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  var authService = locator<AuthService>();
  TextEditingController _c;

  @override
  initState() {
    _c = TextEditingController();
    super.initState();
  }

  Future _addPassword(FirebaseAuthException error) async {
    var password = await showDialog(
        child: Dialog(
          child: Column(
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
          await _addPassword(error);
          await authService.linkWithGoogle(error.credential);
          break;
        case 'password':
          await _addPassword(error);
          break;
        default:
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
                onTap: () => _signInWithFacebook(),
                child: Image.asset('assets/facebook.png')),
            InkWell(
                onTap: () => _signInWithGoogle(),
                child: Image.asset('assets/google.png'))
          ],
        );
      }),
    );
  }
}
