import 'package:camp/models/comment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

var uuid = Uuid();

class CommentService {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final commentsReference = FirebaseFirestore.instance.collection("comments");
  final postsReference = FirebaseFirestore.instance.collection("posts");
  final userReference = FirebaseFirestore.instance.collection("users");
  Dio dio = new Dio();

  Future<List<Comment>> getComments(var postId) async {
    final SharedPreferences prefs = await _prefs;
    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";

    try {
      response = await dio.get("http://10.0.2.2:8000/api/v1/fetch-comment",
          queryParameters: {'productId': postId});
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.error != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }
    }
    List<Comment> comments = [];

    response.data['comments'].forEach(
      (comment) => comments.add(
        Comment.fromJson(comment),
      ),
    );
    return comments;
  }

  postComment(postId, content) async {
    final SharedPreferences prefs = await _prefs;
    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";

    commentsReference.doc(postId.toString()).set({"content": content});

    try {
      response = await dio.post("http://10.0.2.2:8000/api/v1/add-comment",
          data: {'productId': postId, "comment": content});
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.error != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }
    }
    print(response);

    commentsReference.doc(postId.toString()).delete();
  }

  Future<int> getCommentsCount(var postId) async {
    final SharedPreferences prefs = await _prefs;
    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";

    try {
      response = await dio.get(
          "http://10.0.2.2:8000/api/v1/fetch-comment-count",
          queryParameters: {'productId': postId});
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.error != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }
    }
    return response.data['count'];
  }
}
