import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/models/user_account.dart';
import 'package:camp/service_locator.dart';
import 'package:camp/services/CommentService.dart';
import 'package:camp/services/PostService.dart';
import 'package:camp/services/UserService.dart';
import 'package:camp/views/home/components/ItemWidget.dart';
import 'package:camp/views/home/single-item/comment.dart';
import 'package:camp/views/profile/profile.dart';
import 'package:camp/views/styles.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SingleView extends StatefulWidget {
  final post;
  const SingleView({Key key, @required this.post}) : super(key: key);
  @override
  _SingleViewState createState() => _SingleViewState();
}

class _SingleViewState extends State<SingleView> {
  int _current = 0;
  final List<String> images = [];
  var _tapPosition;

  UserService userService = locator<UserService>();
  CommentService commentService = locator<CommentService>();
  UserAccount user;

  PostService _postService = locator<PostService>();
  BehaviorSubject<List<DocumentSnapshot>> postController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.post['files'].forEach((file) {
        images.add(file);
      });
      images.forEach((imageUrl) {
        precacheImage(NetworkImage(imageUrl), context);
      });
      postUser();
      setState(() {});
    });
    postController = BehaviorSubject<List<DocumentSnapshot>>();
    super.initState();
  }

  Stream<List<DocumentSnapshot>> get postStream => postController.stream;
  postUser() async {
    user = await userService.user(widget.post['userId']);
    setState(() {});
  }

  relatedPosts() async {
    List<DocumentSnapshot> related =
        await _postService.searchPosts(widget.post['keywords']);
    setState(() {
      postController.sink.add(related);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios, size: 25, color: Colors.grey.shade500),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GestureDetector(
            onTapDown: _storePosition,
            onTap: () {
              _showMenu();
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(FlutterIcons.ellipsis1_ant,
                  size: 40, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: images.length > 0
                ? Column(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Stack(
                        children: [
                          CarouselSlider.builder(
                            options: CarouselOptions(
                                autoPlay: false,
                                height: viewportConstraints.maxHeight * 0.6,
                                viewportFraction: 6,
                                enableInfiniteScroll: false,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _current = index;
                                  });
                                }),
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Image(
                                  image:
                                      CachedNetworkImageProvider(images[index]),
                                  fit: BoxFit.fitWidth);
                            },
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Row(
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
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 5),
                              color: Colors.grey.shade300,
                              blurRadius: 5)
                        ],
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(50),
                          bottomLeft: Radius.circular(50),
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user != null
                                  ? CachedNetworkImageProvider(user.profileUrl)
                                  : AssetImage(
                                      'assets/6181e48ceed63c198f7c787dbfc4fc48.jpg'),
                            ),
                            title: Padding(
                              padding: EdgeInsets.only(top: 15.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('From',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ProfilePage(
                                                  user: user,
                                                ))),
                                    child: Text(
                                      widget.post['author'],
                                      style: TextStyle(
                                          color: kText,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      FlutterIcons.favorite_border_mdi,
                                      color: Colors.grey,
                                      size: 25,
                                    ),
                                    Icon(
                                      FlutterIcons.share_sli,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                    Icon(
                                      CupertinoIcons.bookmark,
                                      color: Colors.grey,
                                      size: 25,
                                    )
                                  ],
                                ),
                                width: viewportConstraints.maxWidth * 0.3),
                            subtitle: RatingBar(
                              initialRating: 3,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 10,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 0.02),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible: widget.post['forSale'] == true
                                            ? true
                                            : false,
                                        child: Text(
                                          widget.post['title'],
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Visibility(
                                        visible: widget.post['forSale'] == true
                                            ? true
                                            : false,
                                        child: SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 30.0, top: 10, bottom: 10),
                                        child: Text(
                                          widget.post['content'],
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: widget.post['forSale'] == true
                                      ? true
                                      : false,
                                  child: Container(
                                    height: 100,
                                    color: Colors.grey,
                                    width: 0.5,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Visibility(
                                      visible: widget.post['forSale'] == true
                                          ? true
                                          : false,
                                      child: Text(
                                        '₦ ${widget.post['amount']}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
                      child: InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Comment(
                                      postId: widget.post['id'],
                                    ))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            widget.post['commentCount'] == 0
                                ? Text(
                                    'Be the first to comment',
                                    style: TextStyle(color: Colors.grey),
                                  )
                                : Text(
                                    'View all ${widget.post['commentCount']} comments',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                            Icon(
                              Icons.add_comment,
                              size: 30,
                            )
                          ],
                        ),
                      ),
                    ),
                    // Column(
                    //   children: [
                    //     ListTile(
                    //       contentPadding: EdgeInsets.only(left: 10, right: 10),
                    //       leading: CircleAvatar(
                    //         backgroundColor: Colors.red,
                    //         radius: 20,
                    //       ),
                    //       title: Text(
                    //         'SAmson Aka',
                    //         style: TextStyle(fontWeight: FontWeight.bold),
                    //       ),
                    //       subtitle: Text(
                    //         'this is a really long comment i want to leave on a post in the app I nlpsd',
                    //         style: TextStyle(color: Colors.black),
                    //       ),
                    //     ),
                    //     ListTile(
                    //         contentPadding:
                    //             EdgeInsets.only(left: 10, right: 10, bottom: 0),
                    //         leading: CircleAvatar(
                    //           backgroundColor: Colors.red,
                    //           radius: 20,
                    //         ),
                    //         title: Text(
                    //           'SAmson Aka',
                    //           style: TextStyle(fontWeight: FontWeight.bold),
                    //         ),
                    //         subtitle: Column(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           children: [
                    //             Text(
                    //               'this is a really long comment i want to leave on a post in the app I nlpsd',
                    //               style: TextStyle(color: Colors.black),
                    //             ),
                    //             ExpansionTile(
                    //               tilePadding: EdgeInsets.only(
                    //                   left: 0, right: 0, top: 0),
                    //               expandedCrossAxisAlignment:
                    //                   CrossAxisAlignment.end,
                    //               childrenPadding: EdgeInsets.zero,
                    //               title: Text(
                    //                 'Reply (200)',
                    //                 style: TextStyle(fontSize: 10),
                    //               ),
                    //               children: [
                    //                 Column(children: [
                    //                   ListTile(
                    //                     contentPadding: EdgeInsets.zero,
                    //                     leading: CircleAvatar(
                    //                       backgroundColor: Colors.red,
                    //                       radius: 20,
                    //                     ),
                    //                     title: Text(
                    //                       'John Thomas',
                    //                       style: TextStyle(
                    //                           fontWeight: FontWeight.bold),
                    //                     ),
                    //                     subtitle: Text(
                    //                         'this is a really long comment i want to leave on a post in the app I nlpsd'),
                    //                   ),
                    //                   ListTile(
                    //                     contentPadding: EdgeInsets.zero,
                    //                     leading: CircleAvatar(
                    //                       backgroundColor: Colors.red,
                    //                       radius: 20,
                    //                     ),
                    //                     title: Text(
                    //                       'John Thomas',
                    //                       style: TextStyle(
                    //                           fontWeight: FontWeight.bold),
                    //                     ),
                    //                     subtitle: Text(
                    //                         'this is a really long comment i want to leave on a post in the app I nlpsd'),
                    //                   ),
                    //                 ]),
                    //                 Padding(
                    //                   padding: EdgeInsets.only(left: 50.0),
                    //                   child: Column(children: [
                    //                     ListTile(
                    //                       contentPadding: EdgeInsets.zero,
                    //                       leading: CircleAvatar(
                    //                         backgroundColor: Colors.red,
                    //                         radius: 30,
                    //                       ),
                    //                       title: Text(
                    //                         'John Thomas',
                    //                         style: TextStyle(
                    //                             fontWeight: FontWeight.bold),
                    //                       ),
                    //                     ),
                    //                     Padding(
                    //                       padding: EdgeInsets.only(
                    //                           left: 80.0, right: 20),
                    //                       child: Text(
                    //                         'this is a really long comment i want to leave on a post in the app I nlpsd',
                    //                         style:
                    //                             TextStyle(color: Colors.black),
                    //                       ),
                    //                     ),
                    //                   ]),
                    //                 )
                    //               ],
                    //             ),
                    //           ],
                    //         )),
                    //   ],
                    // ),
                    SizedBox(height: 10),
                    Text(
                      'Related Posts',
                      style: TextStyle(fontSize: 18),
                    ),
                    Padding(
                        padding:
                            EdgeInsets.only(left: 10.0, right: 10, top: 20),
                        child: suggestedBuilder()),
                  ])
                : Center(
                    child: Text('loading..'),
                  ),
          );
        },
      ),
    ));
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
          child: Text("Report post"),
        ),
        PopupMenuItem(
          child: Text("Hide"),
        ),
        PopupMenuItem(
          child: Text("Delete"),
        ),
      ],
      elevation: 8.0,
    );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  StreamBuilder<List<DocumentSnapshot>> suggestedBuilder() {
    return StreamBuilder<List<DocumentSnapshot>>(
        stream: postStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StaggeredGridView.count(
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
          }
          return Container(
            child: Padding(
              padding: EdgeInsets.all(38.0),
              child: Center(
                  child: Text(
                'No similar item(s) found',
                style: TextStyle(color: kGrey),
              )),
            ),
          );
        });
  }

  void dispose() {
    super.dispose();
    postController.close();
  }
}
