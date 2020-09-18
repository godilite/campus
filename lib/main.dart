import 'package:camp/service_locator.dart';
import 'package:camp/services/AuthService.dart';
import 'package:camp/views/auth/register.dart';
import 'package:camp/views/followers/stagga.dart';
import 'package:camp/views/home/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camp',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: InitialCheck(),
    );
  }
}

class InitialCheck extends StatefulWidget {
  @override
  _InitialCheckState createState() => _InitialCheckState();
}

class _InitialCheckState extends State<InitialCheck> {
  var _auth = locator<AuthService>();
  bool isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    _auth.auth.authStateChanges().listen((User user) {
      user == null ? isLoggedIn = false : isLoggedIn = true;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? HomeView() : RegisterPage();
  }
}
