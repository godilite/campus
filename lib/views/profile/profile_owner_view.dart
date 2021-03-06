import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/models/activity_model.dart';
import 'package:camp/models/user_account.dart';
import 'package:camp/services/AuthService.dart';
import 'package:camp/services/PostService.dart';
import 'package:camp/services/UserService.dart';
import 'package:camp/views/followers/follower_page.dart';
import 'package:camp/views/home/components/ItemWidget.dart';
import 'package:camp/views/layouts/drawer_scaffold.dart';
import 'package:camp/views/messaging/widgets/full_photo.dart';
import 'package:camp/views/post/widgets/color_loader_2.dart';
import 'package:camp/views/profile/edit_profile.dart';
import 'package:camp/views/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers.dart';
import '../../service_locator.dart';

class ProfileOwnPage extends StatefulWidget {
  @override
  _ProfileOwnPageState createState() => _ProfileOwnPageState();
}

class _ProfileOwnPageState extends State<ProfileOwnPage> {
  var _tapPosition;
  BehaviorSubject<List<Datum>> postController;
  PostService _postService = locator<PostService>();
  UserService _userService = locator<UserService>();
  AuthService _authService = locator<AuthService>();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int followersCount = 0;
  int followingCount = 0;
  String profileUrl;
  String coverPhoto;
  List<Datum> documentList = [];
  UserAccount user;

  @override
  void initState() {
    _setProfile();
    postController = BehaviorSubject<List<Datum>>();
    _getUser().then((value) {
      _fetchFirstList();
      _fetchFriends();
    });
    super.initState();
  }

  Stream<List<Datum>> get userPostStream => postController.stream;
  _fetchFirstList() async {
    Activity posts = await _postService.getUserPosts(user.id);
    documentList.addAll(posts.data);
    postController.sink.add(documentList);
  }

  _setProfile() async {
    final SharedPreferences prefs = await _prefs;
    coverPhoto = prefs.getString('coverPhoto');
    profileUrl = prefs.getString('profileUrl');
  }

  _fetchFriends() async {
    var result = await _userService.getFollowersCount(user.id);
    var follows = await _userService.getFollowingCount(user.id);
    setState(() {
      followersCount = result;
      followingCount = follows;
    });
  }

  Future _getUser() async {
    _authService.userReference
        .doc(_authService.auth.currentUser.uid)
        .snapshots()
        .listen((event) async {
      UserAccount _user = await _authService.currentUser();
      setState(() {
        user = _user;
      });
    });
    return await Future.delayed(const Duration(seconds: 20));
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Material(child: Center(child: ColorLoader2()));
    } else {
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
              image: DecorationImage(
                image: coverPhoto != null
                    ? CachedNetworkImageProvider(coverPhoto)
                    : AssetImage('assets/img_not_available.jpeg'),
                fit: BoxFit.cover,
              ),
              color: kYellow,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
          ),
        ),
        Positioned(
            bottom: 105,
            right: 0,
            left: 0,
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                BoxShadow(blurRadius: 20, color: Colors.black26)
              ]),
              child: CircleAvatar(
                backgroundColor: kYellow,
                minRadius: 37,
                child: user != null && profileUrl != null
                    ? InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullPhoto(url: profileUrl)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image(
                              width: 70,
                              height: 70,
                              fit: BoxFit.fill,
                              image: CachedNetworkImageProvider(
                                profileUrl,
                              )),
                        ),
                      )
                    : Icon(Icons.account_circle, size: 60.0, color: kLightGrey),
              ),
            )),
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
                    child: Text(truncate(20, user.name),
                        overflow: TextOverflow.ellipsis,
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
                      CupertinoIcons.ellipsis,
                      size: 25,
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
                          Row(
                            children: [
                              Icon(CupertinoIcons.location),
                              Text(truncate(15, user.address)),
                            ],
                          ),
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Column(
                              children: [
                                Text('Posts'),
                                Text('${documentList.length}')
                              ],
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Container(
                                padding: EdgeInsets.only(left: 4.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    left:
                                        BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FollowerPage(
                                        0,
                                        user.id,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text('Followers'),
                                      Text('$followersCount')
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Container(
                                padding: EdgeInsets.only(left: 4.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                    left:
                                        BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FollowerPage(
                                        1,
                                        user.id,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text('Following'),
                                      Text('$followingCount')
                                    ],
                                  ),
                                ),
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
            onTapDown: storePosition,
            onTap: () {
              pictureMenu(context).then(
                (value) => setState(() {
                  _setProfile();
                }),
              );
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

  StreamBuilder<List<Datum>> buildStreamBuilder() {
    return StreamBuilder<List<Datum>>(
        stream: userPostStream,
        builder: (context, snapshot) {
          if (snapshot.data == null &&
              snapshot.connectionState != ConnectionState.done) {
            return SliverToBoxAdapter(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: ColorLoader2()),
                ),
              ),
            );
          }
          if (snapshot.data.isEmpty) {
            return SliverToBoxAdapter(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                    'No Posts',
                    style: TextStyle(color: kText),
                  )),
                ),
              ),
            );
          }
          return SliverStaggeredGrid.count(
            crossAxisCount: 4,
            children: snapshot.data.map((Datum post) {
              return ItemWidget(post: post);
            }).toList(),
            staggeredTiles: snapshot.data
                .map<StaggeredTile>((_) => StaggeredTile.fit(2))
                .toList(),
            mainAxisSpacing: 20,
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
          child: InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditProfile(
                          user: user,
                        ))),
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
}
