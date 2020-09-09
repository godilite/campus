import 'package:flutter/material.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: viewportConstraints.maxHeight),
              child: Stack(children: [
                // remaining stuffs
              ]),
            ),
          );
        },
      ),
      extendBody: true,
      bottomNavigationBar: FloatingNavbar(
        onTap: (int val) {
          //returns tab id which is user tapped
        },
        currentIndex: 0,
        items: [
          FloatingNavbarItem(icon: Icons.home, title: ''),
          FloatingNavbarItem(icon: Icons.explore, title: ''),
          FloatingNavbarItem(icon: Icons.chat_bubble_outline, title: ''),
          FloatingNavbarItem(icon: Icons.settings, title: ''),
        ],
      ),
    );
  }
}
