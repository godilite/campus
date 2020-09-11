import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    Key key,
    @required double width,
  })  : _width = width,
        super(key: key);

  final double _width;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned(
          child: Container(
            height: 200,
            width: _width * 0.45,
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(10)),
          ),
        ),
        Positioned(
            top: 10,
            right: 10,
            child: Icon(
              FlutterIcons.favorite_border_mdi,
              color: Colors.white,
            )),
        Positioned(
          bottom: 20,
          left: 30,
          right: 30,
          child: Container(
            height: 35,
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    ));
  }
}
