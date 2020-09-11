import 'package:camp/views/layouts/app_bar_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Following extends StatefulWidget {
  @override
  _FollowingState createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: PageAppbar(
              title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                FlutterIcons.users_fea,
                size: 18,
              ),
              Icon(
                FlutterIcons.check_ant,
                size: 18,
              ),
              SizedBox(width: 5),
              Text('Following', style: TextStyle(color: Colors.grey))
            ],
          ))),
      Positioned(
          top: 145, left: 0, right: 0, bottom: 0, child: ListView(children: []))
    ]));
  }
}
