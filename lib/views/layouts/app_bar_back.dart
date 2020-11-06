import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../styles.dart';

class PageAppbar extends StatelessWidget {
  const PageAppbar({
    Key key,
    @required this.title,
  }) : super(key: key);

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      color: Colors.transparent,
      padding: EdgeInsets.only(top: 40, left: 5, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        ///
        children: <Widget>[
          SizedBox(
            width: 20,
            height: 20,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context, true),
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: kText,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 5, bottom: 1),
                child: title,
              ),
            ],
          )
        ],
      ),
    );
  }
}
