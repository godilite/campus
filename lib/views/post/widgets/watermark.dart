import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/views/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class Watermark extends StatefulWidget {
  final String url;
  final String username;
  Watermark({@required this.url, @required this.username});
  @override
  _WatermarkState createState() => _WatermarkState();
}

class _WatermarkState extends State<Watermark> {
  static GlobalKey previewContainer = GlobalKey();
  Future<Null> screenShotAndShare(context) async {
    try {
      RenderRepaintBoundary boundary =
          previewContainer.currentContext.findRenderObject();
      if (boundary.debugNeedsPaint) {
        Timer(Duration(seconds: 1), () => screenShotAndShare(context));
        return null;
      }
      ui.Image image = await boundary.toImage();
      final directory = (await getExternalStorageDirectory()).path;
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      File imgFile = new File('$directory/screenshot.png');
      imgFile.writeAsBytes(pngBytes);
      // print('Screenshot Path:' + imgFile.path);
      final RenderBox box = context.findRenderObject();
      return Navigator.pop(context, [imgFile, box]);
    } on PlatformException catch (e) {
      print("Exception while taking screenshot:" + e.toString());
    }
  }

  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => screenShotAndShare(context));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: RepaintBoundary(
        key: previewContainer,
        child: CustomMultiChildLayout(
            delegate: MyDelegate(objectCenter: FractionalOffset(1, 1)),
            children: [
              LayoutId(
                id: _Slot.image,
                // Use AspectRatio to emulate an image
                child: Image(image: CachedNetworkImageProvider(widget.url)),
              ),
              LayoutId(
                id: _Slot.circle,
                child: Column(
                  children: [
                    Text('Campusel',
                        style: TextStyle(
                            color: kYellow,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    Text(
                      '@${widget.username}',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )
                  ],
                ),
              )
            ]),
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
