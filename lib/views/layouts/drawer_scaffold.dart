import 'package:camp/service_locator.dart';
import 'package:camp/services/AuthService.dart';
import 'package:camp/views/home/homepage.dart';
import 'package:camp/views/post/create_post.dart';
import 'package:camp/views/profile/profile.dart';
import 'package:camp/views/styles.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
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
  var logout = locator<AuthService>();

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
        return logout.logout();
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

  _getPage(int pos) {
    switch (pos) {
      case 0:
        return Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => HomeView()));
      case 2:
        return Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => CreatePost()));
      case 4:
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ProfilePage()));

      //   case 3:
      //     return Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //             builder: (BuildContext context) => TripHistory()));
      //   case 4:
      //     return Navigator.push(context,
      //         MaterialPageRoute(builder: (BuildContext context) => Payout()));
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

  // var loginService = locator<LoginService>();
  // var firestoreService = locator<FirestoreService>();
  _onSelectItem(int drawScaffold) {
    _getDrawerItemWidget(drawScaffold);
  }

  // UserModel user;
  // DocumentModel docs;
  // @override
  // void initState() {
  //   getUser().then((value) async {
  //     docs = await firestoreService.getDocs(value);
  //     print(docs.profileUrl);
  //     setState(() {});
  //   });
  //   super.initState();
  // }

  // Future getUser() async {
  //   user = await loginService.user;
  //   print(user.firstName);
  //   return user;
  // }

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
                  // backgroundImage: docs != null
                  //     ? NetworkImage('${docs.profileUrl}')
                  //     : AssetImage('assets/chat.png'),
                  minRadius: 35,
                  maxRadius: 35,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                'User Name',
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
              color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
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
                padding: const EdgeInsets.all(8.0),
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
                  FloatingNavbarItem(icon: FlutterIcons.favorite_border_mdi),
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
