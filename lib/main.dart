import 'package:camp/service_locator.dart';
import 'package:camp/views/auth/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return RegisterPage();
  }
}
