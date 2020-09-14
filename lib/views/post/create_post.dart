import 'dart:io';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camp/views/layouts/drawer_scaffold.dart';
import 'package:camp/views/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:dotted_border/dotted_border.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  String _postId = 'ssas';
  List<String> imageList = [];
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  int _current = 0;
  final _postKey = GlobalKey();
  bool _isForSale = false;

  Widget buildPreview() {
    return CarouselSlider.builder(
      options: CarouselOptions(
        autoPlay: false,
        viewportFraction: 1.0,
        height: MediaQuery.of(context).size.width,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: MediaQuery.of(context).size.width.toInt(),
          height: MediaQuery.of(context).size.width.toInt(),
          quality: 80,
        );
      },
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 4,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#FAB70A",
          actionBarTitle: "Campusel",
          allViewTitle: "All Photos",
          useDetailsView: true,
          selectCircleStrokeColor: "#FAB70A",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  void _setForSale(value) {
    setState(() {
      _isForSale = value;
    });
  }

  Future<String> uploadImage() async {
    ByteData image = await images[0].getByteData();
    final temps = await getTemporaryDirectory();
    final path = temps.path;
    //Todo::compress this file
    final time = DateTime.now().toIso8601String();
    final tempFile = File('$path/img_$_postId$time.jpg')
      ..writeAsBytesSync(image.buffer.asUint8List());
    imageList.add(tempFile.path);
  }

  @override
  Widget build(BuildContext context) {
    return DrawScaffold('', LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(bottom: 60.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                images.isEmpty
                    ? InkWell(
                        onTap: () => loadAssets(),
                        child: Container(
                          height: viewportConstraints.maxHeight * 0.3,
                          decoration: BoxDecoration(color: kLightGrey),
                          child: DottedBorder(
                            color: kYellow,
                            strokeWidth: 2,
                            dashPattern: [10, 10],
                            child: Center(
                              child: Icon(
                                FlutterIcons.add_a_photo_mdi,
                                color: kYellow,
                                size: 70,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Flexible(fit: FlexFit.loose, child: buildPreview()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: images.map((url) {
                    int index = images.indexOf(url);
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == index
                            ? Color.fromRGBO(0, 0, 0, 0.9)
                            : Color.fromRGBO(0, 0, 0, 0.4),
                      ),
                    );
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Add location'),
                      Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Icon(
                          FlutterIcons.add_location_mdi,
                          color: kYellow,
                          size: 30,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: IconButton(
                            icon: Icon(
                              FlutterIcons.add_a_photo_mdi,
                              color: kYellow,
                              size: 30,
                            ),
                            onPressed: () => loadAssets()),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Wrap(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          filled: true,
                          border: InputBorder.none,
                          hintText: 'Write something...',
                        ),
                        keyboardType: TextInputType.multiline,
                        minLines: null,
                        maxLines: null,
                      )
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    color: kLightGrey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('For Sale?'),
                        Switch(
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            value: _isForSale,
                            activeTrackColor: kYellow,
                            activeColor: Colors.white,
                            onChanged: (value) => _setForSale(value))
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: _isForSale,
                  child: buildForSaleColumn(),
                ),
                SizedBox(height: 15),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        key: _postKey,
                        color: kYellow,
                        onPressed: () => {},
                        child: Text('Post'))),
              ]),
        ),
      );
    }), true, 2);
  }

  Column buildForSaleColumn() {
    return Column(
      children: [
        SizedBox(height: 15),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              decoration: InputDecoration(
                  filled: true,
                  hintText: 'Item Name',
                  border: InputBorder.none),
            )),
        SizedBox(height: 15),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              decoration: InputDecoration(
                  filled: true, hintText: 'Amount', border: InputBorder.none),
            )),
        SizedBox(height: 15),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              decoration: InputDecoration(
                  filled: true,
                  hintText: 'Where are you shipping to?',
                  border: InputBorder.none),
            )),
      ],
    );
  }
}
