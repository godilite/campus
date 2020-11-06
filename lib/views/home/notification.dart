import 'dart:async';

import 'package:camp/services/UserService.dart';
import 'package:camp/views/messaging/message_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:camp/views/home/single-item/comment.dart';
import '../../helpers.dart';
import '../../service_locator.dart';
import '../styles.dart';

class NotificationPage extends StatefulWidget {
  final int userId;
  final String uid;
  NotificationPage({@required this.userId, @required this.uid});
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List _lists = [];
  final _listController = StreamController<List>.broadcast();
  UserService _userService = locator<UserService>();
  Stream<List> get notificationStream => _listController.stream;
  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((event) async {
      print(event);
      Stream items = Stream.fromFuture(_userService.notifications());

      if (!_isDisposed) {
        items.listen((event) {
          _lists.addAll(event);
          _listController.sink.add(event);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 15.0,
                bottom: 0,
                left: 0,
                right: 0,
                child: buildAppBar(context, constraints),
              ),
              Positioned(
                top: 80,
                bottom: 0,
                left: 0,
                right: 0,
                child: notifications(),
              )
            ],
          ),
        ),
      );
    });
  }

  Container buildAppBar(context, constraints) {
    return Container(
      height: 100,
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: kText,
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Notifications',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: kText),
          )
        ],
      ),
    );
  }

  Container notifications() {
    return Container(
      child: StreamBuilder(
        stream: notificationStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kYellow),
              ),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(5.0),
              itemBuilder: (context, index) =>
                  buildItem(context, snapshot.data[index]),
              itemCount: snapshot.data.length,
            );
          }
        },
      ),
    );
  }

  Widget buildItem(BuildContext context, document) {
    if (document['type'] == "App\\Notifications\\CommentNotification") {
      return FutureBuilder(
          future:
              _userService.user(int.parse(document['data']['commenter_id'])),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('');
            }
            return Container(
              margin: EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: document['read_at'] == null
                      ? Colors.yellow.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(color: kYellow, width: 0.5)),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Comment(
                      postId: int.parse(document['data']['post_id']),
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text('${snapshot.data.name} commented on your post',
                      style: TextStyle(color: kText)),
                  subtitle: Text(truncate(50, document['data']['comment']),
                      style: TextStyle(color: kGrey, fontSize: 12)),
                ),
              ),
            );
          });
    }
    if (document['type'] == "App\\Notifications\\RecieveNotification") {
      return FutureBuilder(
          future: _userService.user(document['data']['sender_id']),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('');
            }
            return Container(
              margin: EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                  color: document['read_at'] == null
                      ? Colors.yellow.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(color: kYellow, width: 0.5),
                  borderRadius: BorderRadius.circular(7)),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessageList(
                        currentUserId: widget.userId, uid: widget.uid),
                  ),
                ),
                child: ListTile(
                  title: Text('new message from ${snapshot.data.name}',
                      style: TextStyle(color: kText)),
                  subtitle: Text(truncate(50, document['data']['message']),
                      style: TextStyle(color: kGrey, fontSize: 12)),
                ),
              ),
            );
          });
    }
    return Text('');
  }

  bool _isDisposed = false;
  void dispose() {
    super.dispose();
    _listController.close();
    _isDisposed = true;
    _userService.markAsRead();
  }
}
