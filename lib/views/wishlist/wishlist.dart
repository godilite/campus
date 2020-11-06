import 'package:flutter/material.dart';

import '../styles.dart';

class WishList extends StatefulWidget {
  @override
  _WishListState createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(children: [
            Positioned(
              top: 15.0,
              bottom: 0,
              left: 0,
              right: 0,
              child: buildAppBar(context, constraints),
            ),
          ]),
        ),
      );
    });
  }
}

Container buildAppBar(context, constraints) {
  return Container(
    height: 90,
    padding: EdgeInsets.only(left: 10, right: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: kText,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'My Wishlist',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: kGrey),
        )
      ],
    ),
  );
}
