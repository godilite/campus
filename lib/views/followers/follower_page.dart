import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/models/user_account.dart';
import 'package:camp/services/UserService.dart';
import 'package:camp/views/post/widgets/color_loader_2.dart';
import 'package:camp/views/profile/profile.dart';
import 'package:camp/views/styles.dart';
import 'package:flutter/material.dart';
import '../../service_locator.dart';

class FollowerPage extends StatefulWidget {
  final int index;
  final int uid;

  FollowerPage(this.index, this.uid);

  @override
  _FollowerPageState createState() => _FollowerPageState();
}

class _FollowerPageState extends State<FollowerPage>
    with TickerProviderStateMixin {
  TabController _tabController;
  //Future _getFollows;
  int id;
  UserService _userService = locator<UserService>();
  // _following(int uid) async {
  //   bool following = await _userService.youAreFollowing(uid);
  //   return following;
  // }

  List followers = [];
  int followersCount = 0;
  int followingCount = 0;
  List following = [];

  // Future _fetchFollowers() async {
  //   var result = await _userService.getFollowers(widget.uid);
  //   followers.addAll(result['followers']);
  //   followersCount = result['total'];
  //   return result;
  // }

  // Future _fetchFollowing() async {
  //   var follows = await _userService.getFollowing(widget.uid);
  //   setState(() {
  //     following.addAll(follows['following']);
  //     followingCount = follows['total'];
  //   });
  // }

  _fetchCurrentId() async {
    id = await _userService.currentId();
  }

  _tabBarView() {
    return TabBarView(
      children: [
        Container(
          child: FutureBuilder(
              future: _userService.getFollowers(widget.uid),
              builder: (context, dataSnapshot) {
                if (!dataSnapshot.hasData) {
                  return Center(
                    child: Container(
                      height: 30,
                      width: 30,
                      child: ColorLoader2(
                        color1: Colors.red,
                        color2: Colors.yellow,
                        color3: Colors.blue,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(),
                    itemCount: dataSnapshot.data['followers'].length,
                    itemBuilder: (context, index) {
                      UserAccount user = dataSnapshot.data['followers'][index];
                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => ProfilePage(
                              user: user,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: SizedBox(
                            width: 40,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image(
                                image: user.profileUrl != null
                                    ? CachedNetworkImageProvider(
                                        user.profileUrl,
                                      )
                                    : AssetImage(
                                        'assets/icons8-male-user-100.png'),
                              ),
                            ),
                          ),
                          title: Text('${user.name}'),
                          subtitle: Text('@${user.username}'),
                          trailing: user.id == id
                              ? Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Text(
                                    'You',
                                    style: TextStyle(
                                        color: kText,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : FutureBuilder(
                                  future: _userService.youAreFollowing(user.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData)
                                      return FlatButton(
                                        color: snapshot.data == true
                                            ? kYellow
                                            : Colors.transparent,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 40),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            side: BorderSide(color: kYellow)),
                                        child: Text(
                                          snapshot.data == true
                                              ? 'Unfollow'
                                              : 'Follow',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        onPressed: () {
                                          snapshot.data == true
                                              ? _userService.unfollow(user.id)
                                              : _userService.follow(user.id);
                                        },
                                      );
                                    return Container(
                                      height: 20,
                                      width: 20,
                                      child: ColorLoader2(
                                        color1: Colors.red,
                                        color2: Colors.yellow,
                                        color3: Colors.blue,
                                      ),
                                    );
                                  }),
                        ),
                      );
                    });
              }),
        ),
        Container(
          child: FutureBuilder(
              future: _userService.getFollowing(widget.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Container(
                      height: 30,
                      width: 30,
                      child: ColorLoader2(
                        color1: Colors.red,
                        color2: Colors.yellow,
                        color3: Colors.blue,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                    separatorBuilder: (BuildContext context, int) => Divider(),
                    itemCount: snapshot.data['following'].length,
                    itemBuilder: (context, index) {
                      UserAccount user = snapshot.data['following'][index];

                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => ProfilePage(
                              user: user,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: SizedBox(
                            width: 40,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image(
                                image: user.profileUrl != null
                                    ? CachedNetworkImageProvider(
                                        user.profileUrl,
                                      )
                                    : AssetImage(
                                        'assets/icons8-male-user-100.png'),
                              ),
                            ),
                          ),
                          title: Text('${user.name}'),
                          subtitle: Text('@${user.username}'),
                          trailing: user.id == id
                              ? Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Text(
                                    'You',
                                    style: TextStyle(
                                        color: kText,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : FutureBuilder(
                                  future: _userService.youAreFollowing(user.id),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData)
                                      return FlatButton(
                                        color: snapshot.data == true
                                            ? kYellow
                                            : Colors.transparent,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 40),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            side: BorderSide(color: kYellow)),
                                        child: Text(
                                          snapshot.data == true
                                              ? 'Unfollow'
                                              : 'Follow',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        ),
                                        onPressed: () {
                                          snapshot.data == true
                                              ? _userService.unfollow(user.id)
                                              : _userService.follow(user.id);
                                        },
                                      );
                                    return Container(
                                      height: 20,
                                      width: 20,
                                      child: ColorLoader2(
                                        color1: Colors.red,
                                        color2: Colors.yellow,
                                        color3: Colors.blue,
                                      ),
                                    );
                                  }),
                        ),
                      );
                    });
              }),
        ),
      ],
      controller: _tabController,
    );
  }

  _tabBar() {
    return PreferredSize(
      preferredSize: Size(200.0, 60.0),
      child: Container(
        height: 40,
        margin: EdgeInsets.only(bottom: 20),
        child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: kText,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50), color: kText),
            tabs: [
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Followers"),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("Following"),
                  ),
                ),
              )
            ]),
      ),
    );
  }

  @override
  void initState() {
    _fetchCurrentId();
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: widget.index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  size: 25, color: Colors.grey.shade600),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: _tabBar(),
          ),
          body: _tabBarView(),
        ),
      ),
    );
  }
}
