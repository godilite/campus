import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/service_locator.dart';
import 'package:camp/services/CommentService.dart';
import 'package:camp/views/profile/profile.dart';
import 'package:camp/views/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:camp/models/comment_model.dart' as c;

class Comment extends StatefulWidget {
  final int postId;

  Comment({this.postId});
  @override
  _CommentState createState() => _CommentState(postId);
}

class _CommentState extends State<Comment> {
  final int postId;

  _CommentState(this.postId);

  CommentService commentService = locator<CommentService>();
  TextEditingController _commentController = TextEditingController();

  List<c.Comment> _list = [];
  final _listController = StreamController<List<c.Comment>>.broadcast();
  Stream<List<c.Comment>> get listStream => _listController.stream;

  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    // Here you need to load your first page and then add to your stream

    commentService.commentsReference
        .doc(widget.postId.toString())
        .snapshots()
        .listen((event) {
      fetch();
    });
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
    Stream<List<c.Comment>> items =
        Stream.fromFuture(commentService.getComments(postId));
    if (!_isDisposed) {
      items.listen((event) {
        _listController.add(event);
        _list.addAll(event);
      });
    }
  }

  _fetchMore() async {
    // _lastComment = _list.last.comment.id;
    // DocumentSnapshot lastDoc = await commentService.commentsReference
    //     .doc(postId)
    //     .collection('comments')
    //     .doc(_lastComment)
    //     .get();
    // Stream<List<CombineStream>> snapList =
    //     await commentService.getMoreComments(postId, lastDoc);
    // snapList.listen((event) {
    //   _list.addAll(event);
    // });
    // _listController.add(_list);
  }

  displayComments() {
    return StreamBuilder<List>(
        stream: listStream,
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            separatorBuilder: (BuildContext context, int) => Divider(),
            controller: controller,
            itemCount: dataSnapshot.data.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: dataSnapshot.data[index].user.profileUrl == null
                    ? InkWell(
                        onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(
                                    user: dataSnapshot.data[index].user),
                              ),
                            ),
                        child: Icon(Icons.account_circle, size: 50))
                    : InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(
                                user: dataSnapshot.data[index].user),
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: CachedNetworkImageProvider(
                              "${dataSnapshot.data[index].user.profileUrl}"),
                        ),
                      ),
                title: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(user: dataSnapshot.data[index].user),
                    ),
                  ),
                  child: Text(
                    "${dataSnapshot.data[index].user.name}",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                subtitle: Text('${dataSnapshot.data[index].comment}'),
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
                onPressed: () => _submitComment(),
                color: kYellow,
              ),
            )
          ]);
        }),
      ),
    );
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _listController.close();

    _isDisposed = true;

    _commentController.dispose();
    super.dispose();
  }
}
