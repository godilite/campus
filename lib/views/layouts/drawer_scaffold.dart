import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/models/user_account.dart';
import 'package:camp/service_locator.dart';
import 'package:camp/services/AuthService.dart';
import 'package:camp/views/home/homepage.dart';
import 'package:camp/views/post/create_post.dart';
import 'package:camp/views/profile/profile_owner_view.dart';
import 'package:camp/views/search/search.dart';
import 'package:camp/views/styles.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class DrawerItem {
  String title;
  DrawerItem(this.title);
}

class DrawScaffold extends StatefulWidget {
  final String title;
  final Widget body;
  final bool bottomNav;
  final int currentPageIndex;
  DrawScaffold(this.title, this.body, [this.bottomNav, this.currentPageIndex]);

  final drawerItems = [
    DrawerItem("Wallet"),
    DrawerItem("Messages"),
    DrawerItem("Edit Account"),
    DrawerItem("Settings"),
    DrawerItem("Logout"),
  ];
  @override
  _DrawScaffoldState createState() => _DrawScaffoldState();
}

class _DrawScaffoldState extends State<DrawScaffold> {
  AuthService _authService = locator<AuthService>();
  UserAccount user;

  /// side bar items
  _getDrawerItemWidget(int pos) {
    print(pos);
    switch (pos) {
      //   case 0:
      //     return Navigator.push(context,
      //         MaterialPageRoute(builder: (BuildContext context) => Dashboard()));
      //   case 1:
      //     return Navigator.push(context,
      //         MaterialPageRoute(builder: (BuildContext context) => Wallet()));
      //   case 2:
      //     return Navigator.push(context,
      //         MaterialPageRoute(builder: (BuildContext context) => Chat()));
      //   case 3:
      //     return Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (BuildContext context) => TripHistory()));
      case 4:
        return _authService.logout();
      //   case 5:
      //     return Navigator.push(context,
      //         MaterialPageRoute(builder: (BuildContext context) => Setting()));
      //   case 6:
      //     return Navigator.push(context,
      //         MaterialPageRoute(builder: (BuildContext context) => Support()));
      //   case 7:
      //     return Navigator.push(context,
      //         MaterialPageRoute(builder: (BuildContext context) => About()));
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
      case 4:
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ProfileOwnPage(
                      user: user,
                    )));
      default:
        return new Text("Error");
    }
  }

  _onSelectItem(int drawScaffold) {
    _getDrawerItemWidget(drawScaffold);
  }

  @override
  void initState() {
    getUser();

    super.initState();
  }

  Future getUser() async {
    UserAccount _user = await _authService.currentUser();
    setState(() {
      user = _user;
    });
  }

  @override
  Widget build(BuildContext context) {
    int _currentPageIndex = widget.currentPageIndex ?? 0;
    var drawerOptions = <Widget>[
      DrawerHeader(
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 25.0),
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  backgroundImage: user != null
                      ? CachedNetworkImageProvider('${user.profileUrl}')
                      : AssetImage(
                          'assets/6181e48ceed63c198f7c787dbfc4fc48.jpg'),
                  minRadius: 35,
                  maxRadius: 35,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                user != null ? user.name : '',
//                    '${user != null ? user.firstName : ''} ${user != null ? user.lastName : ''}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            ]),
      )
    ];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      drawerOptions.add(ListTile(
        dense: true,
        leading: Icon(Icons.access_alarms),
        title: Text(
          d.title,
          style: TextStyle(
              color: kText, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onTap: () => _onSelectItem(i),
      ));
    }
    return SafeArea(
      child: Scaffold(
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(50),
                  child: IconButton(
                      icon: Icon(FlutterIcons.align_left_fea,
                          color: Colors.white),
                      onPressed: () => Scaffold.of(context).openDrawer()),
                ));
          }),
        ),
        drawer: Drawer(
            child: ListView(padding: EdgeInsets.zero, children: drawerOptions)),
        body: widget.body,
        extendBody: true,
        bottomNavigationBar: widget.bottomNav
            ? FloatingNavbar(
                backgroundColor: Colors.white,
                borderRadius: 50,
                itemBorderRadius: 10,
                shadowBlurRadius: 5,
                shadowSpreadRadius: 0,
                unselectedItemColor: kGrey,
                padding: EdgeInsets.only(left: 5, right: 5, top: 8, bottom: 8),
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                selectedBackgroundColor: kGrey,
                selectedItemColor: Colors.white,
                onTap: (int val) {
                  _getPage(val);
                },
                currentIndex: _currentPageIndex,
                items: [
                  FloatingNavbarItem(icon: FlutterIcons.home_ant),
                  FloatingNavbarItem(icon: CupertinoIcons.search),
                  FloatingNavbarItem(
                      icon: FlutterIcons.md_add_circle_outline_ion),
                  FloatingNavbarItem(icon: FlutterIcons.bell_outline_mco),
                  FloatingNavbarItem(icon: FlutterIcons.user_circle_faw5),
                ],
              )
            : null,
      ),
    );
  }
}
