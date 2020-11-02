import 'package:camp/models/user_account.dart';
import 'package:camp/views/auth/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:camp/main.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  FirebaseAuth auth = FirebaseAuth.instance;
  final userReference = FirebaseFirestore.instance.collection("users");
  final usernameReference = FirebaseFirestore.instance.collection("username");
  final DateTime timestamp = DateTime.now();
  String baseUrl = 'http://campusel.ogarnkang.com/api';
  Dio dio = new Dio();
  Future signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      //   Create a credential from the access token
      final FacebookAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(result.accessToken.token);

      UserCredential user =
          await auth.signInWithCredential(facebookAuthCredential);
      // Once signed in, return the UserCredential
      return await _createAccount(user);
    } on FirebaseAuthException catch (e) {
      String email = e.email;
      if (e.code == 'account-exists-with-different-credential') {
        // Fetch a list of what sign-in methods exist for the conflicting user
        List<String> userSignInMethods =
            await auth.fetchSignInMethodsForEmail(email);

        if (userSignInMethods.first == 'google.com') {
          var result = {'error': e, 'method': 'google.com'};
          return result;
        }

        if (userSignInMethods.first == 'password') {
          var result = {'error': e, 'method': 'password'};
          return result;
        }
      }
      var result = {'error': e, 'method': ''};
      return result;
    } catch (e) {}
  }

  Future signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      var user = await auth.signInWithCredential(credential);

      return await _createAccount(user);
    } on FirebaseAuthException catch (e) {
      print(e);
      String email = e.email;
      if (e.code == 'account-exists-with-different-credential') {
        // Fetch a list of what sign-in methods exist for the conflicting user
        List<String> userSignInMethods =
            await auth.fetchSignInMethodsForEmail(email);

        if (userSignInMethods.first == 'facebook.com') {
          var result = {'error': e, 'method': 'facebook.com'};
          return result;
        }
        if (userSignInMethods.first == 'password') {
          var result = {'error': e, 'method': 'password'};
          return result;
        }
      }
      var result = {'error': e, 'method': ''};
      return result;
    }
  }

  Future signInWithEmailAndPassword(String email, var password) async {
    try {
      // Once signed in, return the UserCredential
      var user =
          await auth.signInWithEmailAndPassword(email: email, password: email);

      return await _createAccount(user);
    } on FirebaseAuthException catch (e) {
      print(e.code);
      String email = e.email;
      if (e.code == 'account-exists-with-different-credential') {
        // Fetch a list of what sign-in methods exist for the conflicting user
        List<String> userSignInMethods =
            await auth.fetchSignInMethodsForEmail(email);

        if (userSignInMethods.first == 'facebook.com') {
          var result = {'error': e, 'method': 'facebook.com'};
          return result;
        }
        if (userSignInMethods.first == 'google.com') {
          var result = {'error': e, 'method': 'google.com'};
          return result;
        }
      }
      var result = {'error': e, 'method': ''};
      return result;
    }
  }

  Future createWithEmailAndPassword(email, password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return await _createAccount(userCredential);
    } on FirebaseAuthException catch (e) {
      String email = e.email;
      if (e.code == 'account-exists-with-different-credential') {
        // Fetch a list of what sign-in methods exist for the conflicting user
        List<String> userSignInMethods =
            await auth.fetchSignInMethodsForEmail(email);

        if (userSignInMethods.first == 'google.com') {
          var result = {'error': e, 'method': 'google.com'};
          return result;
        }

        if (userSignInMethods.first == 'facebook.com') {
          var result = {'error': e, 'method': 'facebook.com'};
          return result;
        }
      }
      var result = {'error': e, 'method': ''};
      return result;
    } catch (e) {
      print(e.toString());
    }
  }

  void logout() {
    auth.signOut();
  }

  //Account Linking methods
  Future<UserCredential> linkWithFacebook(pendingCredential) async {
    final LoginResult result = await FacebookAuth.instance.login();

    String token = result.accessToken.token;

    FacebookAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(token);

    // Sign the user in with the credential
    UserCredential userCredential =
        await auth.signInWithCredential(facebookAuthCredential);

    // Link the pending credential with the existing account

    await userCredential.user.linkWithCredential(pendingCredential);

    // Success! Go back to your application flow
    return userCredential;
  }

  Future<UserCredential> linkWithGoogle(pendingCredential) async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    // Create a new credential
    final GoogleAuthCredential googleCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign the user in with the credential
    UserCredential userCredential =
        await auth.signInWithCredential(googleCredential);

    // Link the pending credential with the existing account
    await userCredential.user.linkWithCredential(pendingCredential);
    return userCredential;
  }

  Future<UserCredential> linkWithPassword(
      email, String password, pendingCredential) async {
    // Prompt the user to enter their password

    // Sign the user in to their account with the password
    UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Link the pending credential with the existing account
    await userCredential.user.linkWithCredential(pendingCredential);

    // Success! Go back to your application flow
    return userCredential;
  }

  Future<UserAccount> _createAccount(UserCredential user) async {
    DocumentSnapshot documentSnapshot =
        await userReference.doc(user.user.uid).get();
    UserAccount account;
    if (!documentSnapshot.exists) {
      final userData = await navigatorKey.currentState.push(
        MaterialPageRoute(
          builder: (context) => CreateAccount(),
        ),
      );
      account = await storeUserToBackup(user, userData);
      userReference.doc(user.user.uid).set({
        'id': account.id,
        'name': userData.displayName,
        'username': userData.username,
        'email': user.user.email,
        'profileUrl': user.user.photoURL,
        'phone': userData.phone,
        'bio': '',
        'coverPhoto': '',
        'uid': user.user.uid,
        'address': userData.address,
        'cord': userData.coord,
        'postCount': 0,
        'rating': '0',
        'ratingList': [],
        'followers': 0,
        'following': 0,
        'timestamp': timestamp
      });
    }

    loginUserToBackupServer();
    return account;
  }

  Future<bool> checkifUsernameExist(String username) async {
    DocumentSnapshot usernameSnapshot =
        await usernameReference.doc(username).get();
    if (usernameSnapshot.exists) return false;

    return true;
  }

  Future<UserAccount> currentUser() async {
    final SharedPreferences prefs = await _prefs;

    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";

    try {
      response = await dio.get(
        "http://campusel.ogarnkang.com/api/v1/current/user",
      );
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
    if (response.data.runtimeType == String) {
      await loginUserToBackupServer();
      return currentUser();
    }
    UserAccount user = UserAccount.fromJson(response.data['account']);
    return user;
  }

  Future<UserAccount> storeUserToBackup(UserCredential user, data) async {
    var token = await user.user.getIdToken();
    Response response;
    try {
      response =
          await dio.post("http://campusel.ogarnkang.com/api/v1/login", data: {
        "token": token,
        'name': data.displayName,
        'username': data.username,
        'email': user.user.email,
        'profileUrl': user.user.photoURL,
        'phone': data.phone,
        'bio': '',
        'uid': user.user.uid,
        'coverPhoto': '',
        'address': data.address,
        'long': data.coord.longitude,
        'lat': data.coord.latitude
      });
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
    final SharedPreferences prefs = await _prefs;
    prefs.setString('token', response.data["access_token"]);
    prefs.setInt('userId', response.data["id"]);
    prefs.setString('uid', response.data["account"]['uid']);
    prefs.setString('profileUrl', response.data["account"]['profileUrl']);
    prefs.setString('coverPhoto', response.data["account"]['coverPhoto']);

    UserAccount account = UserAccount.fromJson(response.data["account"]);
    return account;
  }

  loginUserToBackupServer() async {
    Response response;
    var token = await auth.currentUser.getIdToken();

    try {
      response = await dio.post("http://campusel.ogarnkang.com/api/v1/login",
          data: {"token": token});
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
    final SharedPreferences prefs = await _prefs;
    prefs.setString('token', response.data["access_token"]);
    prefs.setInt('userId', response.data["id"]);
    prefs.setString('uid', response.data["account"]['uid']);
    prefs.setString('profileUrl', response.data["account"]['profileUrl']);
    prefs.setString('coverPhoto', response.data["account"]['coverPhoto']);
  }

  Future<bool> updateUserToBackup(data) async {
    final SharedPreferences prefs = await _prefs;

    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";
    try {
      await dio.post("http://campusel.ogarnkang.com/api/v1/update-user", data: {
        'name': data['displayName'],
        'username': data['username'],
        'email': data['email'],
        'phone': data['phone'],
        'bio': '',
        'address': data['address'],
        'long': data['coord'].longitude,
        'lat': data['coord'].latitude
      });
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

    return true;
  }

  Future<bool> updateUserPix(String url) async {
    final SharedPreferences prefs = await _prefs;

    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";
    try {
      await dio
          .post("http://campusel.ogarnkang.com/api/v1/update-user-pix", data: {
        'profileUrl': url,
      });
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

    return true;
  }

  Future<bool> updateUserCover(String url) async {
    Response response;
    final SharedPreferences prefs = await _prefs;

    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";
    try {
      response = await dio.post(
          "http://campusel.ogarnkang.com/api/v1/update-user-cover",
          data: {
            'coverPhoto': url,
          });
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

    return true;
  }
}
