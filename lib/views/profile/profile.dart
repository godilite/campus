import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/models/user_account.dart';
import 'package:camp/services/PostService.dart';
import 'package:camp/services/UserService.dart';
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

import '../../helpers.dart';
import '../../service_locator.dart';

class ProfilePage extends StatefulWidget {
  final UserAccount user;
  ProfilePage({this.user});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _tapPosition;
  BehaviorSubject<List<DocumentSnapshot>> postController;
  PostService _postService = locator<PostService>();
  UserService _userService = locator<UserService>();
  List<DocumentSnapshot> documentList = [];
  @override
  void initState() {
    postController = BehaviorSubject<List<DocumentSnapshot>>();
    _fetchFirstList();
    _following();
    super.initState();
  }

  bool _isFollowing;
  _following() async {
    _isFollowing = await _userService.isFollowing(widget.user.id);
    setState(() {});
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
    ), false);
  }

  Stack profileStack(BoxConstraints viewportConstraints) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 150,
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
              minRadius: 50,
              child: widget.user != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image(
                        image: widget.user.profileUrl != null
                            ? CachedNetworkImageProvider(
                                widget.user.profileUrl,
                              )
                            : AssetImage('assets/icons8-male-user-100.png'),
                      ),
                    )
                  : null,
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
                    child: Text(truncate(20, widget.user.name),
                        style: TextStyle(
                          color: kText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        )),
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
              return ItemWidget(post: post.data());
            }).toList(),
            staggeredTiles: snapshot.data
                .map<StaggeredTile>((_) => StaggeredTile.fit(2))
                .toList(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 10,
          );
        });
  }

  Future<void> _showMenu() async {
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
              Icon(CupertinoIcons.phone),
              SizedBox(
                width: 20,
              ),
              Text("Call")
            ],
          ),
        ),
        PopupMenuItem(
          child: InkWell(
            onTap: () {
              _isFollowing
                  ? _userService.unfollow(widget.user.id)
                  : _userService.follow(widget.user.id);

              setState(() {
                _isFollowing = !_isFollowing;
              });
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Icon(CupertinoIcons.person_alt_circle),
                SizedBox(
                  width: 20,
                ),
                _isFollowing ? Text("Unfollow") : Text('Follow')
              ],
            ),
          ),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(CupertinoIcons.mail),
              SizedBox(
                width: 20,
              ),
              Text("Message")
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
}
