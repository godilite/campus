import 'package:camp/models/user_account.dart';
import 'package:camp/streams/combine_followers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Dio dio = new Dio();

  FirebaseFirestore rootRef = FirebaseFirestore.instance;
  final userReference = FirebaseFirestore.instance.collection("users");
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<UserAccount> user(String id) async {
    final SharedPreferences prefs = await _prefs;

    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";

    try {
      response = await dio.get("http://10.0.2.2:8000/api/v1/user/account",
          queryParameters: {"id": 1});
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

    UserAccount user = UserAccount.fromJson(response.data["account"]);
    return user;
  }

  ///Follow user function
  ///This function will take the user id parameter and add this
  /// Id to the auth user following, also adds the auth user to the followers
  ///  list of the given user
  follow(int uid) async {
    return true;
  }

  Future<bool> isFollowing(int uid) async {
    return false;
  }

  unfollow(int uid) async {
    return true;
  }

  getFollowers(int uid) {
    return;
  }

  getFollowing(int uid) {
    return;
  }
}
