import 'package:camp/models/user_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Dio dio = new Dio();

  FirebaseFirestore rootRef = FirebaseFirestore.instance;
  final userReference = FirebaseFirestore.instance.collection("users");
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<UserAccount> user(int id) async {
    final SharedPreferences prefs = await _prefs;

    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";

    try {
      response = await dio.get(
          "http://campusel.ogarnkang.com/api/v1/user/account",
          queryParameters: {"id": id});
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.error != null) {
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }
    }

    UserAccount user = UserAccount.fromJson(response.data["account"]);
    return user;
  }

  ///Follow user function
  ///This function will take the user id parameter and add this
  /// Id to the auth user following, also adds the auth user to the followers
  ///  list of the given user
  follow(int uid) async {
    final SharedPreferences prefs = await _prefs;

    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";
    try {
      response = await dio.post("http://campusel.ogarnkang.com/api/v1/follow",
          data: {"id": uid});
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.error != null) {
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }
    }
    print(response.data);
    return response.data;
  }

  Future<bool> youAreFollowing(int uid) async {
    final SharedPreferences prefs = await _prefs;

    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";

    try {
      response = await dio.get(
          "http://campusel.ogarnkang.com/api/v1/youAreFollowing",
          queryParameters: {"id": uid});
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
    return response.data['following'];
  }

  Future<bool> followingYou(int uid) async {
    return false;
  }

  unfollow(int uid) async {
    final SharedPreferences prefs = await _prefs;

    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";
    try {
      response = await dio.post("http://campusel.ogarnkang.com/api/v1/unfollow",
          data: {"id": uid});
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
    print(response.data);
    return response.data;
  }

  getFollowers(int uid) async {
    final SharedPreferences prefs = await _prefs;

    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";
    List<UserAccount> followers = [];
    try {
      response = await dio.get("http://campusel.ogarnkang.com/api/v1/followers",
          queryParameters: {"id": uid});
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

    response.data['data'].forEach((user) {
      followers.add(UserAccount.fromJson(user));
    });
    return {'followers': followers, 'total': response.data['total']};
  }

  getFollowersCount(int uid) async {
    final SharedPreferences prefs = await _prefs;

    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";
    try {
      response = await dio.get(
          "http://campusel.ogarnkang.com/api/v1/followersCount",
          queryParameters: {"id": uid});
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
    return int.parse(response.data);
  }

  getFollowingCount(int uid) async {
    final SharedPreferences prefs = await _prefs;

    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";
    try {
      response = await dio.get(
          "http://campusel.ogarnkang.com/api/v1/followingCount",
          queryParameters: {"id": uid});
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
    return int.parse(response.data);
  }

  getFollowing(int uid) async {
    final SharedPreferences prefs = await _prefs;

    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";
    List<UserAccount> following = [];
    try {
      response = await dio.get("http://campusel.ogarnkang.com/api/v1/following",
          queryParameters: {"id": uid});
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

    response.data['data'].forEach((user) {
      following.add(UserAccount.fromJson(user));
    });
    return {'following': following, 'total': response.data['total']};
  }

  currentId() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getInt('userId');
  }

  void storeChat(int uid, String message) async {
    final SharedPreferences prefs = await _prefs;

    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";
    try {
      await dio.post("http://campusel.ogarnkang.com/api/v1/messages/send",
          data: {"reciever_id": uid, 'message': message});
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.error != null) {
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }
    }
  }

  Future allChat() async {
    final SharedPreferences prefs = await _prefs;

    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";
    try {
      response = await dio.get(
        "http://campusel.ogarnkang.com/api/v1/messages",
      );
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.error != null) {
      } else {
        // Something happened in setting up or sending the request that triggered an Error
      }
    }
    return response.data;
  }

  Future notifications() async {
    final SharedPreferences prefs = await _prefs;

    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";
    try {
      response = await dio.get(
        "http://campusel.ogarnkang.com/api/v1/user/notifications",
      );
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      print(e);
    }
    return response.data;
  }

  void markAsRead() async {
    final SharedPreferences prefs = await _prefs;

    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";
    try {
      await dio.get(
        "http://campusel.ogarnkang.com/api/v1/user/mark-as-read",
      );
    } on DioError catch (e) {
      print(e);
    }
  }
}
