import 'package:camp/services/PostService.dart';
import 'package:camp/views/layouts/app_bar_back.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

import '../../service_locator.dart';
import '../styles.dart';

class Following extends StatefulWidget {
  @override
  _FollowingState createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  bool showAll = false;
  PostService _postService = locator<PostService>();

  @override
  void initState() {
    _postService.getUserFrendsPosts();
    super.initState();
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
                      buildPost(viewportConstraints),
                      buildPost(viewportConstraints),
                      buildPost(viewportConstraints),
                    ]),
              ),
            ))
      ]));
    });
  }

  Column buildPost(BoxConstraints viewportConstraints) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.all(0),
          leading: CircleAvatar(
            backgroundColor: Colors.red,
            radius: 30,
          ),
          title: Text('My friend name'),
        ),
        SizedBox(height: 10),
        StaggeredGridView.countBuilder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 4,
          itemCount: 8,
          itemBuilder: (BuildContext context, int index) => Shimmer.fromColors(
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
        ),

        // StaggeredGridView.count(
        //   shrinkWrap: true,
        //   padding: EdgeInsets.all(0),
        //   crossAxisCount: 4,
        //   physics: NeverScrollableScrollPhysics(),
        //   children: [],
        //   staggeredTiles: const <StaggeredTile>[
        //     const StaggeredTile.fit(2),
        //     const StaggeredTile.fit(2),
        //     const StaggeredTile.fit(2),
        //     const StaggeredTile.fit(2),
        //     const StaggeredTile.fit(2),
        //     const StaggeredTile.fit(2),
        //     const StaggeredTile.fit(2),
        //     const StaggeredTile.fit(2),
        //   ],
        //   mainAxisSpacing: 10,
        //   crossAxisSpacing: 10,
        // ),
        // ItemWidget(width: viewportConstraints.maxWidth * 0.45),
        // ItemWidget(width: viewportConstraints.maxWidth * 0.45),
        // ItemWidget(width: viewportConstraints.maxWidth * 0.45),
        // ItemWidget(width: viewportConstraints.maxWidth * 0.45),
        //   ],
        //   staggeredTiles: const <StaggeredTile>[
        //     const StaggeredTile.fit(2),
        //     const StaggeredTile.fit(2),
        //     const StaggeredTile.fit(2),
        //     const StaggeredTile.fit(2),
        //   ],
        //   mainAxisSpacing: 10,
        //   crossAxisSpacing: 10,
        // ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('(281)'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                FlutterIcons.favorite_border_mdi,
                color: Colors.red,
              ),
            )
          ],
        )
      ],
    );
  }
}
