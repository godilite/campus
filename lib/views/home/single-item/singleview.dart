import 'package:camp/views/home/components/ItemWidget.dart';
import 'package:camp/views/home/single-item/comment.dart';
import 'package:camp/views/profile/profile.dart';
import 'package:camp/views/styles.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SingleView extends StatefulWidget {
  @override
  _SingleViewState createState() => _SingleViewState();
}

class _SingleViewState extends State<SingleView> {
  int _current = 0;
  final List<String> images = [
    'https://images.unsplash.com/photo-1586882829491-b81178aa622e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2850&q=80',
    'https://images.unsplash.com/photo-1586871608370-4adee64d1794?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2862&q=80',
    'https://images.unsplash.com/photo-1586901533048-0e856dff2c0d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
    'https://images.unsplash.com/photo-1586902279476-3244d8d18285?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2850&q=80',
    'https://images.unsplash.com/photo-1586943101559-4cdcf86a6f87?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1556&q=80',
    'https://images.unsplash.com/photo-1586951144438-26d4e072b891?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
    'https://images.unsplash.com/photo-1586953983027-d7508a64f4bb?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80',
  ];
  var _tapPosition;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      images.forEach((imageUrl) {
        precacheImage(NetworkImage(imageUrl), context);
      });
    });
    super.initState();
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
                size: 30, color: Colors.grey.shade700),
            onPressed: () => Navigator.pop(context),
          )),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: Column(children: [
              Container(
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 200,
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
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 200,
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
                      bottom: 200,
                      right: 20,
                      child: Container(
                          height: 130,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                FlutterIcons.md_repeat_ion,
                                color: Colors.white,
                                size: 25,
                              ),
                              Icon(
                                FlutterIcons.share_sli,
                                color: Colors.white,
                                size: 20,
                              ),
                              Icon(
                                FlutterIcons.favorite_border_mdi,
                                color: Colors.white,
                                size: 25,
                              )
                            ],
                          ),
                          width: viewportConstraints.maxWidth * 0.3),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
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
                              leading: CircleAvatar(),
                              title: Row(
                                children: [
                                  Text('From',
                                      style: TextStyle(color: Colors.grey)),
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
                                      'Tenny Collections',
                                      style: TextStyle(color: kText),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: GestureDetector(
                                onTapDown: _storePosition,
                                onTap: () {
                                  _showMenu();
                                },
                                child: Icon(
                                  FlutterIcons.ellipsis1_ant,
                                  size: 40,
                                ),
                              ),
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
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'iPhone X',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 40,
                              right: 40,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [Text('Reviews'), Text('1231')],
                                  ),
                                  FlatButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      color: Color(0xffFAB70A),
                                      onPressed: () => print('Save'),
                                      child: Text('Save')),
                                  Column(
                                    children: [Text('Price'), Text('N 3131')],
                                  ),
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
                padding: EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Comments'),
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
                    contentPadding: EdgeInsets.only(left: 15),
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 30,
                    ),
                    title: Text(
                      'SAmson Aka',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 80.0, right: 20, bottom: 10),
                    child: Text(
                      'this is a really long comment i want to leave on a post in the app I nlpsd',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ExpansionTile(
                    tilePadding: EdgeInsets.only(left: 70, right: 20),
                    expandedCrossAxisAlignment: CrossAxisAlignment.end,
                    childrenPadding: EdgeInsets.zero,
                    title: Text('Reply (200)'),
                    children: [
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
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 80.0, right: 20),
                            child: Text(
                              'this is a really long comment i want to leave on a post in the app I nlpsd',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ]),
                      ),
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
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 80.0, right: 20),
                            child: Text(
                              'this is a really long comment i want to leave on a post in the app I nlpsd',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ]),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: Row(
                      children: [
                        InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Comment())),
                            child: Text('10 more comments >>')),
                      ],
                    ),
                  )
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
            ]),
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
