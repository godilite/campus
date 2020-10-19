import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/models/post_model.dart';
import 'package:camp/models/user_account.dart';
import 'package:camp/services/PostService.dart';
import 'package:camp/views/home/components/ItemWidget.dart';
import 'package:camp/views/layouts/drawer_scaffold.dart';
import 'package:camp/views/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shimmer/shimmer.dart';

import '../../service_locator.dart';

class EditProfile extends StatefulWidget {
  final UserAccount user;
  EditProfile({this.user});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var _tapPosition;
  BehaviorSubject<List<DocumentSnapshot>> postController;
  PostService _postService = locator<PostService>();
  List<DocumentSnapshot> documentList = [];
  @override
  void initState() {
    postController = BehaviorSubject<List<DocumentSnapshot>>();
    _fetchFirstList();
    super.initState();
  }

  Stream<List<DocumentSnapshot>> get userPostStream => postController.stream;
  _fetchFirstList() async {
    List<DocumentSnapshot> posts =
        await _postService.getUserPosts(widget.user.id);
    documentList.addAll(posts);
    postController.sink.add(documentList);
  }

  @override
  Widget build(BuildContext context) {
    return DrawScaffold('', LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return CustomScrollView(slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                child: profileStack(viewportConstraints),
                height: viewportConstraints.maxHeight * 0.5,
                width: viewportConstraints.maxWidth,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200))),
              ),
            ]),
          ),
          buildStreamBuilder(),
        ]);
      },
    ), true, 4);
  }

  Stack profileStack(BoxConstraints viewportConstraints) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 140,
          child: Container(
            decoration: BoxDecoration(
                color: kYellow,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
          ),
        ),
        Positioned(
          bottom: 105,
          right: 0,
          left: 0,
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black26)]),
            child: CircleAvatar(
              backgroundColor: kYellow,
              minRadius: 40,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image(
                  width: 77,
                  image: CachedNetworkImageProvider(
                    widget.user.profileUrl,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 10,
          child: Container(
            height: viewportConstraints.maxHeight * 0.2,
            width: viewportConstraints.maxWidth,
            child: Stack(
              children: [
                Positioned(
                  bottom: 60,
                  left: 15,
                  right: 15,
                  child: Center(
                    child: Text(
                      widget.user.name,
                      style: TextStyle(color: kText, fontSize: 18),
                    ),
                  ),
                ),
                Positioned(
                  right: 15,
                  bottom: 50,
                  child: GestureDetector(
                    onTapDown: _storePosition,
                    onTap: () {
                      _showMenu();
                    },
                    child: Icon(
                      FlutterIcons.ellipsis1_ant,
                      size: 40,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(widget.user.address),
                          RatingBar(
                            initialRating: 3,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 10,
                            itemPadding: EdgeInsets.symmetric(horizontal: 0.02),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text('Posts'),
                                Text('${widget.user.postCount}')
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Container(
                              padding: EdgeInsets.only(left: 8.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text('Followers'),
                                  Text('${widget.user.followers}')
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Container(
                              padding: EdgeInsets.only(left: 8.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text('Following'),
                                  Text('${widget.user.following}')
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTapDown: _storePosition,
            onLongPress: () {
              _pictureMenu();
            },
            child: CircleAvatar(
              minRadius: 30,
              backgroundColor: Colors.black12,
              child: Icon(
                Icons.camera_enhance,
                color: kYellow,
              ),
            ),
          ),
        )
      ],
    );
  }

  StreamBuilder<List<DocumentSnapshot>> buildStreamBuilder() {
    return StreamBuilder<List<DocumentSnapshot>>(
        stream: userPostStream,
        builder: (context, snapshot) {
          if (snapshot.data == null &&
              snapshot.connectionState != ConnectionState.done) {
            return SliverStaggeredGrid.countBuilder(
              crossAxisCount: 4,
              itemCount: 8,
              itemBuilder: (BuildContext context, int index) =>
                  Shimmer.fromColors(
                baseColor: Colors.grey.shade100,
                highlightColor: Colors.white,
                child: Container(
                  width: 200,
                  height: 400,
                  color: Colors.red,
                ),
              ),
              staggeredTileBuilder: (int index) =>
                  StaggeredTile.count(2, index.isEven ? 2 : 1),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
            );
          }
          return SliverStaggeredGrid.count(
            crossAxisCount: 4,
            children: snapshot.data.map((DocumentSnapshot post) {
              return ItemWidget(post: PostModel.fromData(post));
            }).toList(),
            staggeredTiles: snapshot.data
                .map<StaggeredTile>((_) => StaggeredTile.fit(2))
                .toList(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 10,
          );
        });
  }

  void _showMenu() {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    showMenu(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      position: RelativeRect.fromRect(
          _tapPosition & Size(40, 40), Offset.zero & overlay.size),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(CupertinoIcons.pencil_circle),
              SizedBox(
                width: 20,
              ),
              Text("Edit Profile")
            ],
          ),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(CupertinoIcons.antenna_radiowaves_left_right),
              SizedBox(
                width: 20,
              ),
              Text("Boost")
            ],
          ),
        ),
      ],
      elevation: 2.0,
    );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  void dispose() {
    super.dispose();
    postController.close();
  }

  void _pictureMenu() {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    showMenu(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      position: RelativeRect.fromRect(
          _tapPosition & Size(140, 0), Offset.zero & overlay.size),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(CupertinoIcons.photo_camera),
              SizedBox(
                width: 20,
              ),
              Text("Change Cover Photo")
            ],
          ),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(CupertinoIcons.photo_camera),
              SizedBox(
                width: 20,
              ),
              Text("Change Profile Picture")
            ],
          ),
        ),
      ],
      elevation: 2.0,
    );
  }
}
