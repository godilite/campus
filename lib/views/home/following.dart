import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/models/activity_model.dart';
import 'package:camp/services/PostService.dart';
import 'package:camp/views/layouts/app_bar_back.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../service_locator.dart';
import '../styles.dart';

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
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return Scaffold(
          body: Stack(children: <Widget>[
        Positioned(
          left: 10,
          right: 10,
          top: 0,
          bottom: 0,
          child: PageAppbar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      showAll = true;
                      Navigator.pop(context);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                        color: showAll ? kText : Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
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
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                        color: showAll ? Colors.white : kText,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
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
            top: 130,
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
                    ]),
              ),
            ))
      ]));
    });
  }

  StreamBuilder<List<Datum>> buildStreamBuilder(
      BoxConstraints viewportConstraints) {
    return StreamBuilder<List<Datum>>(
        stream: postStream,
        builder: (context, snapshot) {
          if (snapshot.data == null &&
              snapshot.connectionState != ConnectionState.done) {
            return StaggeredGridView.countBuilder(
              shrinkWrap: true,
              crossAxisCount: 4,
              itemCount: 8,
              itemBuilder: (BuildContext context, int index) =>
                  Shimmer.fromColors(
                baseColor: Colors.grey.shade100,
                highlightColor: Colors.white,
                child: Container(
                  width: 200,
                  height: 400,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              staggeredTileBuilder: (int index) =>
                  StaggeredTile.count(2, index.isEven ? 2 : 1),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
            );
          }
          return Column(
            children: snapshot.data.map((Datum post) {
              return buildPost(viewportConstraints, post);
            }).toList(),
          );
        });
  }

  Column buildPost(BoxConstraints viewportConstraints, Datum post) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: CircleAvatar(
            backgroundColor: Colors.red,
            backgroundImage: CachedNetworkImageProvider(post.user.profileUrl),
            radius: 30,
          ),
          title: Text(post.user.name),
        ),
        SizedBox(height: 10),
        StaggeredGridView.countBuilder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 4,
          itemCount: post.details.product.images.length,
          itemBuilder: (BuildContext context, int index) => ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image(
                  image: CachedNetworkImageProvider(
                      post.details.product.images[index]))),
          staggeredTileBuilder: (int index) => StaggeredTile.fit(2),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 8.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('(${post.details.productLikes.length})'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: post.details.productLikes.firstWhere(
                          (element) => element.userId == userId(),
                          orElse: () => null) !=
                      null
                  ? Icon(
                      FlutterIcons.favorite_mdi,
                      color: Colors.red,
                    )
                  : Icon(
                      FlutterIcons.favorite_border_mdi,
                      color: Colors.red,
                    ),
            )
          ],
        )
      ],
    );
  }

  void dispose() {
    super.dispose();
    postController.close();
  }
}
