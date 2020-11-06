import 'dart:io';

import 'package:camp/views/home/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class PushNotificationService {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final notifyReference =
      FirebaseFirestore.instance.collection("notifications");
  FirebaseAuth auth = FirebaseAuth.instance;
  Future initialise() async {
    final SharedPreferences prefs = await _prefs;
    var userId = prefs.getInt('userId');
    var uid = prefs.getString('uid');
    if (Platform.isIOS) {
      _firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings());
    }
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        notifyReference
            .doc(auth.currentUser.uid)
            .set({'notify': message['data']});
      },
      onLaunch: (Map<String, dynamic> message) async {
        navigatorKey.currentState.push(
          MaterialPageRoute(
            builder: (context) => NotificationPage(userId: userId, uid: uid),
          ),
        );
      },
      onResume: (Map<String, dynamic> message) async {
        navigatorKey.currentState.push(
          MaterialPageRoute(
            builder: (context) => NotificationPage(userId: userId, uid: uid),
          ),
        );
      },
    );
  }

  Future<String> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
