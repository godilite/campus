import 'package:camp/models/comment_model.dart';
import 'package:camp/models/user_account.dart';
import 'package:camp/services/AuthService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

var uuid = Uuid();

class CommentService {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final commentsReference = FirebaseFirestore.instance.collection("comments");
  final postsReference = FirebaseFirestore.instance.collection("posts");
  final userReference = FirebaseFirestore.instance.collection("users");
  Dio dio = new Dio();

  getComments(var postId) {}

  getMoreComments(var postId, DocumentSnapshot startAfter) async {}

  postComment(postId, content) async {
    var id = uuid.v1();
  }
}
