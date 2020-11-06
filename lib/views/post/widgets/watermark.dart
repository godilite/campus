import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/models/activity_model.dart';
import 'package:camp/views/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';

class Watermark extends StatefulWidget {
  final String url;
  final Datum post;

  Watermark({@required this.url, @required this.post});
  @override
  _WatermarkState createState() => _WatermarkState();
}

class _WatermarkState extends State<Watermark> {
  GlobalKey previewContainer = GlobalKey();

  int originalSize = 800;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context, true),
          child: Icon(
            CupertinoIcons.chevron_back,
            size: 25,
            color: Colors.grey,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: RepaintBoundary(
              key: previewContainer,
              child: CustomMultiChildLayout(
                  delegate: MyDelegate(objectCenter: FractionalOffset(1, 1)),
                  children: [
                    LayoutId(
                      id: _Slot.image,
                      // Use AspectRatio to emulate an image
                      child:
                          Image(image: CachedNetworkImageProvider(widget.url)),
                    ),
                    LayoutId(
                      id: _Slot.circle,
                      child: Column(
                        children: [
                          Image(
                            image: AssetImage('assets/playstore.png'),
                            width: 30,
                            height: 30,
                          ),
                          Text(
                            '@${widget.post.user.username}',
                            style: TextStyle(
                                color: Colors.yellow.shade700,
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    )
                  ]),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: RaisedButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: kYellow,
                onPressed: () => ShareFilesAndScreenshotWidgets()
                    .shareScreenshot(
                        previewContainer,
                        originalSize,
                        "${widget.post.details.product.title}",
                        "image.png",
                        "image/png",
                        text: "${widget.post.details.product.content}"),
                icon: Icon(Icons.share),
                label: Text('Share')),
          ),
        ],
      ),
    );
  }
}

enum _Slot {
  image,
  circle,
}

class MyDelegate extends MultiChildLayoutDelegate {
  final FractionalOffset objectCenter;

  MyDelegate({@required this.objectCenter});

  @override
  void performLayout(Size size) {
    Size imageSize = Size.zero;
    Offset imagePos = Offset.zero;

    if (hasChild(_Slot.image)) {
      imageSize = layoutChild(_Slot.image, BoxConstraints.loose(size));

      // Center the image in the available space
      imagePos = (size - imageSize as Offset) * 0.5;
      positionChild(_Slot.image, imagePos);
    }

    if (hasChild(_Slot.circle)) {
      Size childSize = layoutChild(_Slot.circle, BoxConstraints());
      positionChild(
          _Slot.circle,
          imagePos +
              objectCenter.alongSize(imageSize) -
              childSize.center(Offset(60, 60)));
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => false;
}
