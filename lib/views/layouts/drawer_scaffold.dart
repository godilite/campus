import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/main.dart';
import 'package:camp/models/user_account.dart';
import 'package:camp/service_locator.dart';
import 'package:camp/services/AuthService.dart';
import 'package:camp/views/home/homepage.dart';
import 'package:camp/views/home/notification.dart';
import 'package:camp/views/messaging/message_list.dart';
import 'package:camp/views/post/create_post.dart';
import 'package:camp/views/profile/edit_profile.dart';
import 'package:camp/views/profile/profile_owner_view.dart';
import 'package:camp/views/search/search.dart';
import 'package:camp/views/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../helpers.dart';

class DrawerItem {
  String title;
  IconData icon;
  DrawerItem(this.title, this.icon);
}

class DrawScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final bool bottomNav;
  final int currentPageIndex;
  DrawScaffold(this.title, this.body, [this.bottomNav, this.currentPageIndex]);

  final drawerItems = [
    // DrawerItem("Wallet", CupertinoIcons.tickets),
    DrawerItem("Messages", CupertinoIcons.mail),
    DrawerItem("Wishlist", CupertinoIcons.bookmark),
    DrawerItem("Insight", CupertinoIcons.chart_bar),
    DrawerItem("Find contacts", CupertinoIcons.person_2_square_stack),
    DrawerItem("Sponsor Ad", CupertinoIcons.cursor_rays),
    DrawerItem("Settings", CupertinoIcons.gear_alt),
    DrawerItem("Logout", CupertinoIcons.square_arrow_right),
  ];
  @override
  _DrawScaffoldState createState() => _DrawScaffoldState();
}

class _DrawScaffoldState extends State<DrawScaffold> {
  AuthService _authService = locator<AuthService>();
  UserAccount user;
  int _count = 0;

  /// side bar items
  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MessageList(
              currentUserId: user.id,
              uid: user.uid,
            ),
          ),
        );
      //   case 1:
      //     return Navigator.push(context,
      //         MaterialPageRoute(builder: (BuildContext context) => Wallet()));
      //   case 2:
      //     return Navigator.push(context,
      //         MaterialPageRoute(builder: (BuildContext context) => Chat()));
      case 3:
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => EditProfile(
                      user: user,
                    )));

      //   case 5:
      //     return Navigator.push(context,
      //         MaterialPageRoute(builder: (BuildContext context) => Setting()));
      //   case 6:
      //     return Navigator.push(context,
      //         MaterialPageRoute(builder: (BuildContext context) => Support()));
      case 6:
        _authService.logout();
        setState(() {});
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => InitialCheck()));
      default:
        return new Text("Error");
    }
  }

  ///Bottom menu bar
  _getPage(int pos) {
    switch (pos) {
      case 0:
        return Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => HomeView()));
      case 1:
        return Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => SearchPage()));
      case 2:
        return Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => CreatePost()));
      case 3:
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    NotificationPage(userId: user.id, uid: user.uid)));
      case 4:
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ProfileOwnPage()));
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int drawScaffold) {
    _getDrawerItemWidget(drawScaffold);
  }

  @override
  void initState() {
    _authService.auth.authStateChanges().listen((User user) {
      user == null ? print('no user') : getUser();
    });
    getNotifications();
    super.initState();
  }

  getUser() async {
    _authService.userReference
        .doc(_authService.auth.currentUser.uid)
        .snapshots()
        .listen((event) async {
      UserAccount _user = await _authService.currentUser();
      if (this.mounted) {
        setState(() {
          user = _user;
        });
      }
    });
  }

  getNotifications() async {
    _authService.notifyReference
        .doc(_authService.auth.currentUser.uid)
        .snapshots()
        .listen((event) async {
      int notifications = await _authService.notifications();
      if (this.mounted) {
        setState(() {
          _count = notifications;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int _currentPageIndex = widget.currentPageIndex ?? 0;
    var drawerOptions = <Widget>[
      Container(
        padding: EdgeInsets.only(bottom: 8),
        child: DrawerHeader(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ProfileOwnPage())),
                      child: CircleAvatar(
                        backgroundColor: kYellow,
                        minRadius: 40,
                        child: user != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image(
                                  height: 80,
                                  width: 80,
                                  image: user.profileUrl != null
                                      ? CachedNetworkImageProvider(
                                          user.profileUrl,
                                        )
                                      : AssetImage(
                                          'assets/icons8-male-user-100.png'),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ProfileOwnPage(),
                    ),
                  ),
                  child: Text(
                    user != null ? user.name : '',
//                    '${user != null ? user.firstName : ''} ${user != null ? user.lastName : ''}',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Text(
                  user != null
                      ? truncate(20, (user.email != null ? user.email : ''))
                      : '',
//                    '${user != null ? user.firstName : ''} ${user != null ? user.lastName : ''}',
                  style: TextStyle(color: kText),
                )
              ]),
        ),
      )
    ];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(ListTile(
        leading: Icon(d.icon),
        title: Text(
          d.title,
          style: TextStyle(
              color: kText, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onTap: () => _onSelectItem(i),
      ));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.all(8.0),
              child: Material(
                elevation: 1,
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(50),
                child: IconButton(
                    icon: Icon(CupertinoIcons.bars, color: kGrey),
                    onPressed: () => Scaffold.of(context).openDrawer()),
              ));
        }),
      ),
      drawer: Drawer(
          child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: drawerOptions)),
      body: widget.body,
      extendBody: true,
      bottomNavigationBar: widget.bottomNav
          ? FloatingNavbar(
              backgroundColor: Colors.white,
              borderRadius: 50,
              itemBorderRadius: 10,
//              shadowColor: Colors.black12,
              // shadowBlurRadius: 5,
              // shadowSpreadRadius: 0,
              unselectedItemColor: kText,
              padding: EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 8),
              margin: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              selectedBackgroundColor: kText,
              selectedItemColor: Colors.white,
              onTap: (int val) {
                _getPage(val);
              },
              currentIndex: _currentPageIndex,
              items: [
                FloatingNavbarItem(icon: CupertinoIcons.house),
                FloatingNavbarItem(icon: CupertinoIcons.search),
                FloatingNavbarItem(icon: CupertinoIcons.add_circled),
                FloatingNavbarItem(icon: CupertinoIcons.bell, counter: _count),
                FloatingNavbarItem(icon: CupertinoIcons.person_circle),
              ],
            )
          : null,
    );
  }
}
