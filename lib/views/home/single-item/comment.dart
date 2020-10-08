import 'dart:async';

import 'package:camp/streams/combine_stream.dart';
import 'package:camp/service_locator.dart';
import 'package:camp/services/CommentService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Comment extends StatefulWidget {
  final String postId;

  Comment({this.postId});
  @override
  _CommentState createState() => _CommentState(postId);
}

class _CommentState extends State<Comment> {
  final String postId;

  _CommentState(this.postId);

  CommentService commentService = locator<CommentService>();
  TextEditingController _commentController = TextEditingController();

  String _lastComment;
  List<CombineStream> _list = [];
  final _listController = StreamController<List<CombineStream>>.broadcast();
  Stream<List<CombineStream>> get listStream => _listController.stream;

  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // Here you need to load your first page and then add to your stream
    fetch();
    controller.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      print("at the end of list");
      _fetchMore();
    }
  }

  fetch() async {
    // List<CombineStream> firstPageItems =
    Stream<List<CombineStream>> items =
        await commentService.getComments(postId);
    items.listen((event) {
      _listController.add(event);
      _list.addAll(event);
    });
  }

  _fetchMore() async {
    _lastComment = _list.last.comment.id;
    DocumentSnapshot lastDoc = await commentService.commentsReference
        .doc(postId)
        .collection('comments')
        .doc(_lastComment)
        .get();
    Stream<List<CombineStream>> snapList =
        await commentService.getMoreComments(postId, lastDoc);
    snapList.listen((event) {
      _list.addAll(event);
    });
    _listController.add(_list);
  }

  displayComments() {
    return StreamBuilder<List<CombineStream>>(
        stream: listStream,
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            controller: controller,
            itemCount: dataSnapshot.data.length,
            itemBuilder: (context, index) {
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                      "${dataSnapshot.data[index].users.profileUrl}"),
                ),
                title: Text(
                  "${dataSnapshot.data[index].users.name}",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${dataSnapshot.data[index].comment.hasReply}"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${dataSnapshot.data[index].comment.timestamp.toDate()}'),
                        dataSnapshot.data[index].comment.hasReply
                            ? Column(
                                children: [
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
                                    ],
                                  ),
                                ],
                              )
                            : Text('reply'),
                      ],
                    )
                  ],
                ),
                trailing: Icon(
                  FlutterIcons.favorite_border_mdi,
                  size: 20,
                ),
              );
            },
          );
        });
  }

  _submitComment() {
    if (_commentController.text.isEmpty) return;
    commentService.postComment(postId, _commentController.text);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text('Comments'),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      size: 25, color: Colors.grey.shade600),
                  onPressed: () => Navigator.pop(context),
                )),
            body: LayoutBuilder(builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return Column(children: [
                Expanded(child: displayComments()),
                Divider(),
                ListTile(
                  contentPadding: EdgeInsets.only(left: 15),
                  title: TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment here',
                    ),
                    minLines: null,
                    maxLines: null,
                  ),
                  trailing: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () => _submitComment()),
                )
              ]);
            })));
  }

  @override
  void dispose() {
    _listController.close();
    _commentController.dispose();
    super.dispose();
  }
}
