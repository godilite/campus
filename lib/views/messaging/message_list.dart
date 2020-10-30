import 'dart:async';

import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/services/UserService.dart';
import 'package:camp/views/messaging/chat.dart';
import 'package:camp/views/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../service_locator.dart';

class MessageList extends StatefulWidget {
  final int currentUserId;
  final String uid;

  MessageList({Key key, @required this.currentUserId, @required this.uid})
      : super(key: key);
  @override
  _MessageListState createState() =>
      _MessageListState(currentUserId: currentUserId, uid: uid);
}

class _MessageListState extends State<MessageList> {
  _MessageListState({@required this.currentUserId, this.uid});
  UserService _userService = locator<UserService>();
  int currentUserId;
  String uid;
  List _lists = [];
  final _listController = StreamController<List>.broadcast();
  Stream<List> get messagesStream => _listController.stream;
  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((event) async {
      print(event);
      Stream items = Stream.fromFuture(_userService.allChat());

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
                child: usersFoundScreen(),
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
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              size: 25,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Messages',
            style: TextStyle(
              fontSize: 18,
            ),
          )
        ],
      ),
    );
  }

  Container usersFoundScreen() {
    return Container(
      child: StreamBuilder(
        stream: messagesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kYellow),
              ),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
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
    String content = document['message'];
    if (document['sender']['id'] == currentUserId) {
      return Bubble(
        radius: Radius.circular(20),
        style: BubbleStyle(
          nipHeight: 20,
          nipWidth: 40,
          nipOffset: 40,
          nip: BubbleNip.leftTop,
          color: Colors.white,
          elevation: 1,
          margin: BubbleEdges.only(
            top: 8.0,
          ),
          alignment: Alignment.topLeft,
        ),
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: document['reciever']['profileUrl'] != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor: AlwaysStoppedAnimation<Color>(kYellow),
                          ),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(15.0),
                        ),
                        imageUrl: document['reciever']['profileUrl'],
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: kGrey,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          '${document['reciever']['name']}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 18),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              child: content.contains(
                                      'https://firebasestorage.googleapis.com/v0/b/cmps')
                                  ? Icon(Icons.image_outlined)
                                  : Text(
                                      '${document['message']}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: kText),
                                    ),
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          child: Text(
                            '${timeago.format(DateFormat("yyyy-MM-dd hh:mm:ss").parse(document['updated_at']))}',
                            style: TextStyle(color: kGrey),
                          ),
                        ),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                          peerId: document['reciever']['uid'],
                          peerCode: document['reciever']['id'],
                          peerName: document['reciever']['name'],
                          peerAvatar: document['reciever']['profileUrl'],
                        )));
          },
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      );
    } else {
      return Bubble(
        style: BubbleStyle(
          nip: BubbleNip.leftTop,
          color: Colors.white,
          elevation: 1,
          margin: BubbleEdges.only(top: 8.0, right: 50.0),
          alignment: Alignment.topLeft,
        ),
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: document['sender']['profileUrl'] != null
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor: AlwaysStoppedAnimation<Color>(kYellow),
                          ),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(15.0),
                        ),
                        imageUrl: document['sender']['profileUrl'],
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: kGrey,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          '${document['sender']['name']}',
                          style: TextStyle(color: Colors.black),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            child: Text(
                              '${document['message'] ?? 'Not available'}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.black),
                            ),
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                          ),
                          Container(
                            child: Text(
                                '${DateFormat("yyyy-MM-dd hh:mm:ss").parse(document['updated_at'])}'),
                          )
                        ],
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                          peerId: document['sender']['uid'],
                          peerCode: document['sender']['id'],
                          peerName: document['sender']['name'],
                          peerAvatar: document['sender']['profileUrl'],
                        )));
          },
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      );
    }
  }

  bool _isDisposed = false;
  void dispose() {
    super.dispose();
    _listController.close();
    _isDisposed = true;
  }
}
