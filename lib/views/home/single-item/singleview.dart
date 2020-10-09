import 'package:camp/models/user_account.dart';
import 'package:camp/service_locator.dart';
import 'package:camp/services/UserService.dart';
import 'package:camp/views/home/components/ItemWidget.dart';
import 'package:camp/views/home/single-item/comment.dart';
import 'package:camp/views/profile/profile.dart';
import 'package:camp/views/styles.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

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

  UserAccount user;

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
    print(widget.post);
    super.initState();
  }

  postUser() async {
    user = await userService.user(widget.post['userId']);
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
            icon: Icon(Icons.arrow_back_ios,
                size: 25, color: Colors.grey.shade700),
            onPressed: () => Navigator.pop(context),
          )),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: images.length > 0
                ? Column(children: [
                    Container(
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          Positioned(
                            top: 0,
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: CarouselSlider.builder(
                              options: CarouselOptions(
                                  autoPlay: false,
                                  height: viewportConstraints.maxHeight,
                                  viewportFraction: 1.0,
                                  enableInfiniteScroll: false,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _current = index;
                                    });
                                  }),
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                return Image.network(
                                  images[index],
                                  width: viewportConstraints.maxWidth,
                                  fit: BoxFit.fitWidth,
                                );
                              },
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 130,
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
                          Positioned(
                            top: 0,
                            right: 0,
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
                            left: 0,
                            right: 0,
                            bottom: -70,
                            child: Container(
                              height: viewportConstraints.maxHeight * 0.3,
                              width: viewportConstraints.maxWidth,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(50),
                                      bottomLeft: Radius.circular(50))),
                              child: Stack(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          user != null ? user.profileUrl : ''),
                                    ),
                                    title: Padding(
                                      padding: EdgeInsets.only(top: 15.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text('From',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w300)),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          InkWell(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfilePage())),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                        width:
                                            viewportConstraints.maxWidth * 0.3),
                                    subtitle: Text('rating'),
                                  ),
                                  Positioned(
                                    top: 70,
                                    left: 20,
                                    right: 20,
                                    bottom: 0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.post['title'],
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w900),
                                              ),
                                              Text(
                                                widget.post['content'],
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          height: 100,
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                        SizedBox(width: 25),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('N 3131',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text('N 3131',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            SizedBox(height: 40),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      height: viewportConstraints.maxHeight * 0.9,
                      width: viewportConstraints.maxWidth,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade300,
                                spreadRadius: 2,
                                blurRadius: 8)
                          ],
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(50),
                              bottomLeft: Radius.circular(50))),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Comment(
                                            postId: widget.post['id'],
                                          ))),
                              child: Text(
                                'View all 10 comments',
                                style: TextStyle(color: Colors.grey),
                              )),
                          Icon(
                            Icons.add_comment,
                            size: 30,
                          )
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.only(left: 10, right: 10),
                          leading: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 20,
                          ),
                          title: Text(
                            'SAmson Aka',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'this is a really long comment i want to leave on a post in the app I nlpsd',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        ListTile(
                            contentPadding:
                                EdgeInsets.only(left: 10, right: 10, bottom: 0),
                            leading: CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 20,
                            ),
                            title: Text(
                              'SAmson Aka',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'this is a really long comment i want to leave on a post in the app I nlpsd',
                                  style: TextStyle(color: Colors.black),
                                ),
                                ExpansionTile(
                                  tilePadding: EdgeInsets.only(
                                      left: 0, right: 0, top: 0),
                                  expandedCrossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  childrenPadding: EdgeInsets.zero,
                                  title: Text(
                                    'Reply (200)',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  children: [
                                    Column(children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 20,
                                        ),
                                        title: Text(
                                          'John Thomas',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                            'this is a really long comment i want to leave on a post in the app I nlpsd'),
                                      ),
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 20,
                                        ),
                                        title: Text(
                                          'John Thomas',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                            'this is a really long comment i want to leave on a post in the app I nlpsd'),
                                      ),
                                    ]),
                                    Padding(
                                      padding: EdgeInsets.only(left: 50.0),
                                      child: Column(children: [
                                        ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.red,
                                            radius: 30,
                                          ),
                                          title: Text(
                                            'John Thomas',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 80.0, right: 20),
                                          child: Text(
                                            'this is a really long comment i want to leave on a post in the app I nlpsd',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ]),
                                    )
                                  ],
                                ),
                              ],
                            )),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Related Posts',
                      style: TextStyle(fontSize: 18),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10, top: 20),
                      child: StaggeredGridView.count(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(0),
                        crossAxisCount: 4,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          ItemWidget(width: 100),
                          ItemWidget(width: 100),
                          ItemWidget(width: 100),
                          ItemWidget(width: 100),
                        ],
                        staggeredTiles: const <StaggeredTile>[
                          const StaggeredTile.fit(2),
                          const StaggeredTile.fit(2),
                          const StaggeredTile.fit(2),
                          const StaggeredTile.fit(2),
                        ],
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                    ),
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
}
