import 'dart:io';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camp/views/layouts/drawer_scaffold.dart';
import 'package:camp/views/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:geocoding/geocoding.dart';

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
  TextEditingController descriptionController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadAssets();
  }

  Widget buildPreview() {
    return CarouselSlider.builder(
      options: CarouselOptions(
        autoPlay: false,
        viewportFraction: 8.0,
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
          quality: 100,
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
          actionBarTitle: "Select photos",
          allViewTitle: "All Photos",
          useDetailsView: true,
          startInAllView: true,
          statusBarColor: "#000000",
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

  _getLocation() async {
    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) await requestPermission();

    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    String address =
        '${place.subThoroughfare} ${place.thoroughfare}, ${place.subLocality} ${place.locality}, ${place.subAdministrativeArea} ${place.administrativeArea}, ${place.country}';
    print(address);
    String specificAddress = '${place.locality}, ${place.country}';
    locationController.text = specificAddress;
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  key: _postKey,
                  color: kYellow.withOpacity(0.9),
                  onPressed: () => {},
                  child: Text('Share'))),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: LayoutBuilder(
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
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
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
                        InkWell(
                          onTap: () => _getLocation(),
                          child: Row(
                            children: [
                              Text('Use current location',
                                  style: TextStyle(color: kGrey)),
                              Icon(
                                FlutterIcons.add_location_mdi,
                                color: kYellow,
                                size: 25,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 20.0),
                          child: IconButton(
                              icon: Icon(
                                FlutterIcons.add_a_photo_mdi,
                                color: kYellow,
                                size: 25,
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
                          controller: descriptionController,
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
                      child: TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                            filled: true,
                            hintText: 'Write your location here',
                            border: InputBorder.none),
                      )),
                  SizedBox(height: 15),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      color: Colors.grey.shade200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('For Sale?'),
                          Switch(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
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
                ]),
          ),
        );
      }),
    );
  }

  Column buildForSaleColumn() {
    return Column(
      children: [
        SizedBox(height: 15),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                  filled: true, hintText: 'Title', border: InputBorder.none),
            )),
        SizedBox(height: 15),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: TextField(
              controller: amountController,
              decoration: InputDecoration(
                  filled: true, hintText: 'Amount', border: InputBorder.none),
            )),
        SizedBox(height: 15),
      ],
    );
  }
}
