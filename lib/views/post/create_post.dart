import 'package:camp/models/post_model.dart';
import 'package:camp/service_locator.dart';
import 'package:camp/services/PostService.dart';
import 'package:camp/services/UploadService.dart';
import 'package:camp/views/home/homepage.dart';
import 'package:camp/views/post/widgets/color_loader_2.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hashtagable/hashtagable.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:camp/views/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:geocoding/geocoding.dart';

import '../../helpers.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  List<String> imageList = [];
  List<Asset> images = List<Asset>();
  int _current = 0;
  final _postKey = GlobalKey();
  bool _isForSale = false;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  PostService postService = locator<PostService>();
  UploadService uploadService = locator<UploadService>();
  double long = 0;
  double lat = 0;
  bool posting = false;
  @override
  void initState() {
    loadAssets();

    super.initState();
  }

  ///creates a carousel preview of selected files
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

  ///Loads user assets from phone
  Future loadAssets() async {
    List<Asset> resultList = List<Asset>();
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 4,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
            actionBarColor: "#FAB70A",
            actionBarTitle: "Select photos",
            lightStatusBar: true,
            allViewTitle: "All Photos",
            useDetailsView: true,
            startInAllView: true,
            statusBarColor: "#000000",
            selectCircleStrokeColor: "#FAB70A",
            textOnNothingSelected: 'Select atleast one file'),
      );
    } on Exception {}

    if (!mounted) return;

    setState(() {
      if (resultList.isEmpty) {
        Navigator.pop(context);
      }
      images = resultList;
    });
  }

  void _setForSale(value) {
    setState(() {
      _isForSale = value;
    });
  }

  ///Gets the current location
  _getLocation() async {
    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) await requestPermission();

    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    String specificAddress = '${place.locality}, ${place.country}';
    setState(() {
      locationController.text = specificAddress;
      long = position.longitude;
      lat = position.latitude;
    });
  }

  List imageFiles = [];

  uploadImages() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeView(),
      ),
    );
    await Future.forEach(images, (image) async {
      var url = (await uploadService.saveImage(image)).toString();

      imageFiles.add(url);
    });
    var post = PostModel(
      forSale: _isForSale,
      location: locationController.text,
      content: descriptionController.text,
      title: titleController.text,
      hashtags: extractHashTags(descriptionController.text),
      images: imageFiles,
      lat: lat,
      long: long,
      keywords: searchKeyword(titleController.text),
      amount: amountController.text.isEmpty
          ? 0.0
          : double.parse(amountController.text),
    );
    postService.post(post).then((value) {
      ///Add count of post to user
      postService.addCount();
      setState(() {
        posting = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeView(),
        ),
      );
    });
  }

  /// creates a new post
  void createPost() async {
    setState(() {
      posting = true;
    });

    /// upload image files
    uploadImages();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    titleController.dispose();
    locationController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: posting ? Colors.white12 : Colors.transparent,
          leading: InkWell(
            onTap: () => Navigator.pop(context, true),
            child: Icon(
              CupertinoIcons.chevron_back,
              size: 30,
              color: Colors.grey,
            ),
          ),
          actions: [
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: posting
                    ? FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        key: _postKey,
                        color: kYellow.withOpacity(0.9),
                        onPressed: () => null,
                        child: Text('Processing...'),
                      )
                    : FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        key: _postKey,
                        color: kYellow.withOpacity(0.9),
                        onPressed: () => createPost(),
                        child: Text('Share'),
                      )),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: posting
                ? Padding(
                    padding: EdgeInsets.only(top: 300.0),
                    child: Center(
                      child: ColorLoader2(
                        color1: Colors.red,
                        color2: Colors.yellow,
                        color3: Colors.blue,
                      ),
                    ),
                  )
                : Padding(
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
                                    decoration:
                                        BoxDecoration(color: kLightGrey),
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
                              : Flexible(
                                  fit: FlexFit.loose, child: buildPreview()),
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
                          Divider(),
                          Padding(
                            padding: EdgeInsets.only(right: 8.0, bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                    onTap: () => _getLocation(),
                                    child: Icon(
                                      FlutterIcons.add_location_mdi,
                                      color: kYellow,
                                      size: 30,
                                    )),
                                SizedBox(width: 10),
                                IconButton(
                                    icon: Icon(
                                      FlutterIcons.add_a_photo_mdi,
                                      color: kYellow,
                                      size: 30,
                                    ),
                                    onPressed: () => loadAssets())
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Wrap(
                              children: [
                                HashTagTextField(
                                  decoratedStyle: TextStyle(
                                      fontSize: 14, color: Colors.blue),
                                  controller: descriptionController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    border: InputBorder.none,
                                    hintText: 'Write something...',
                                  ),
                                  keyboardType: TextInputType.multiline,
                                  minLines: 4,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
      ),
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
