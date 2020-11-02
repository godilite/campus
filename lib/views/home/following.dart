import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/models/activity_model.dart';
import 'package:camp/models/product_like.dart';
import 'package:camp/services/PostService.dart';
import 'package:camp/views/layouts/app_bar_back.dart';
import 'package:camp/views/post/widgets/color_loader_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:like_button/like_button.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../service_locator.dart';
import '../styles.dart';
import 'single-item/singleview.dart';

class Following extends StatefulWidget {
  @override
  _FollowingState createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool showAll = false;
  PostService _postService = locator<PostService>();
  List<Datum> documentList = [];
  BehaviorSubject<List<Datum>> postController;
  @override
  void initState() {
    postController = BehaviorSubject<List<Datum>>();
    _fetchFirstList();
    super.initState();
  }

  userId() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getInt("userId");
  }

  Stream<List<Datum>> get postStream => postController.stream;
  _fetchFirstList() async {
    Activity posts = await _postService.getUserFrendsPosts();
    documentList.addAll(posts.data);
    postController.sink.add(documentList);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(children: <Widget>[
            Positioned(
              left: 10,
              right: 10,
              top: 0,
              bottom: 0,
              child: Container(
                height: 50,
                color: Colors.white,
                padding: EdgeInsets.only(top: 20, left: 5, right: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          showAll = true;
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            color: showAll ? kText : Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.circle_grid_hex,
                              size: 18,
                              color: showAll ? Colors.white : kText,
                            ),
                            SizedBox(width: 10),
                            Text('All',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: showAll ? Colors.white : kText))
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        // showAll = await loadFollowing();
                        setState(() {
                          showAll = false;
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            color: showAll ? Colors.white : kText,
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              CupertinoIcons.person_2,
                              color: showAll ? kText : Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Text('Following',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: showAll ? kText : Colors.white,
                                ))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 65,
              left: 10,
              right: 10,
              bottom: 0,
              child: SingleChildScrollView(
                child: Container(
                  height: viewportConstraints.maxHeight,
                  child: ListView(
                      physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      children: [
                        buildStreamBuilder(viewportConstraints),
                        SizedBox(height: 200),
                      ]),
                ),
              ),
            ),
          ]),
        );
      }),
    );
  }

  StreamBuilder<List<Datum>> buildStreamBuilder(
      BoxConstraints viewportConstraints) {
    return StreamBuilder<List<Datum>>(
        stream: postStream,
        builder: (context, snapshot) {
          if (snapshot.data == null &&
              snapshot.connectionState != ConnectionState.done) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: ColorLoader2()),
              ],
            );
          }

          if (snapshot.hasError &&
              snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: Text('Network Error'),
            );
          }
          return Column(
            children: snapshot.data.map((Datum post) {
              return FollowerPostWidget(post: post);
            }).toList(),
          );
        });
  }

  void dispose() {
    super.dispose();
    postController.close();
  }
}

class FollowerPostWidget extends StatefulWidget {
  const FollowerPostWidget({Key key, @required Datum post})
      : _post = post,
        super(key: key);

  final Datum _post;

  @override
  _FollowerPostWidgetState createState() => _FollowerPostWidgetState();
}

class _FollowerPostWidgetState extends State<FollowerPostWidget> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int _userId;
  PostService _postService = locator<PostService>();
  @override
  void initState() {
    _currentUser();
    super.initState();
  }

  bool liked = false;
  _currentUser() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _userId = prefs.getInt('userId');
    });
  }

  Future<bool> _likePost(liked) async {
    setState(() {
      liked = !liked;
    });

    await _postService.likePost(widget._post.details.product.id);
    return liked;
  }

  @override
  Widget build(BuildContext context) {
    var like = widget._post.details.productLikes
        .where((ProductLike element) => element.userId == _userId);
    // ignore: unnecessary_statements
    like.isNotEmpty ? liked = true : null;
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage:
                CachedNetworkImageProvider(widget._post.user.profileUrl),
            radius: 20,
          ),
          title: Text(
            widget._post.user.name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: widget._post.details.product.title.isNotEmpty
              ? Text(
                  "${widget._post.details.product.title}",
                  style: TextStyle(color: kGrey),
                )
              : Text(
                  "${widget._post.details.product.content}",
                  style: TextStyle(color: kGrey),
                ),
          trailing: Text(widget._post.lapse),
        ),
        SizedBox(height: 10),
        StaggeredGridView.countBuilder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 4,
          itemCount: widget._post.details.product.images.length,
          itemBuilder: (BuildContext context, int index) => ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        SingleView(post: widget._post, liked: liked),
                  ),
                ),
                child: Image(
                    image: CachedNetworkImageProvider(
                        widget._post.details.product.images[index])),
              )),
          staggeredTileBuilder: (int index) => StaggeredTile.fit(
              widget._post.details.product.images.length > 1 ? 2 : 3),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 8.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            LikeButton(
              onTap: _likePost,
              isLiked: liked,
              size: 30,
              circleColor:
                  CircleColor(start: Color(0xffFAB7fc), end: Color(0xffFAB70A)),
              bubblesColor: BubblesColor(
                dotPrimaryColor: Color(0xffccff0A),
                dotSecondaryColor: Color(0xffFAB70A),
              ),
              likeBuilder: (bool liked) {
                return Icon(
                  Icons.favorite,
                  color: liked ? Colors.red : Colors.grey,
                  size: 20,
                );
              },
              likeCount: widget._post.details.productLikes.length,
              countBuilder: (int count, bool liked, String text) {
                var color = liked ? Colors.red : Colors.grey;
                Widget result;
                if (count == 0) {
                  result = Text(
                    "love",
                    style: TextStyle(color: color),
                  );
                } else
                  result = Text(
                    text,
                    style: TextStyle(color: color),
                  );
                return result;
              },
            ),
          ],
        ),
      ],
    );
  }
}
