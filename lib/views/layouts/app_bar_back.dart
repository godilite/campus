import 'package:flutter/material.dart';

class PageAppbar extends StatelessWidget {
  const PageAppbar({
    Key key,
    @required this.title,
  }) : super(key: key);

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      color: Colors.transparent,
      padding: EdgeInsets.only(top: 40, left: 5, right: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        ///
        children: <Widget>[
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              size: 30,
              color: Colors.grey.shade700,
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
