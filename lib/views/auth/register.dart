import 'package:camp/service_locator.dart';
import 'package:camp/services/AuthService.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  var authService = locator<AuthService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Stack(
              children: [
                InkWell(
                    onTap: () => authService.signInWithFacebook(),
                    child: Image.asset('assets/facebook.png'))
              ],
            ),
          ),
        );
      }),
    );
  }
}
