import 'package:camp/views/home/components/ItemWidget.dart';

import 'package:camp/views/layouts/drawer_scaffold.dart';
import 'package:camp/views/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _tapPosition;

  @override
  Widget build(BuildContext context) {
    return DrawScaffold('', LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(children: [
            Container(
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 130,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(50),
                              bottomLeft: Radius.circular(50))),
                    ),
                  ),
                  Positioned(
                    bottom: 90,
                    right: 0,
                    left: 0,
                    child: CircleAvatar(
                      minRadius: 50,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: Container(
                      height: viewportConstraints.maxHeight * 0.2,
                      width: viewportConstraints.maxWidth,
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 50,
                            left: 20,
                            right: 20,
                            child: Center(
                              child: Text(
                                'Tenny Collections',
                                style: TextStyle(color: kText),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 20,
                            bottom: 40,
                            child: GestureDetector(
                              onTapDown: _storePosition,
                              onTap: () {
                                _showMenu();
                              },
                              child: Icon(
                                FlutterIcons.ellipsis1_ant,
                                size: 40,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 20,
                            right: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [Text('Lagos'), Text('rating')],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [Text('Posts'), Text('3131')],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Container(
                                        padding: EdgeInsets.only(left: 8.0),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left:
                                                    BorderSide(color: kGrey))),
                                        child: Column(
                                          children: [
                                            Text('Followers'),
                                            Text('3131')
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Container(
                                        padding: EdgeInsets.only(left: 8.0),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                left:
                                                    BorderSide(color: kGrey))),
                                        child: Column(
                                          children: [
                                            Text('Following'),
                                            Text('3131')
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              height: viewportConstraints.maxHeight * 0.5,
              width: viewportConstraints.maxWidth,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: kGrey))),
            ),
            SizedBox(height: 20),
            Text(
              'Reposts',
              style: TextStyle(fontSize: 18),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10, top: 20),
              child: StaggeredGridView.count(
                shrinkWrap: true,
                padding: EdgeInsets.all(0),
                crossAxisCount: 4,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ItemWidget(width: 100),
                  ItemWidget(width: 100),
                  ItemWidget(width: 100),
                  ItemWidget(width: 100),
                  ItemWidget(width: 100),
                  ItemWidget(width: 100),
                  ItemWidget(width: 100),
                  ItemWidget(width: 100),
                ],
                staggeredTiles: const <StaggeredTile>[
                  const StaggeredTile.fit(2),
                  const StaggeredTile.fit(2),
                  const StaggeredTile.fit(2),
                  const StaggeredTile.fit(2),
                  const StaggeredTile.fit(2),
                  const StaggeredTile.fit(2),
                  const StaggeredTile.fit(2),
                  const StaggeredTile.fit(2),
                ],
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
            ),
          ]),
        );
      },
    ), true, 4);
  }

  void _showMenu() {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    showMenu(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      position: RelativeRect.fromRect(
          _tapPosition & Size(40, 40), Offset.zero & overlay.size),
      items: [
        PopupMenuItem(
          child: Text("Call"),
        ),
        PopupMenuItem(
          child: Text("Follow"),
        ),
        PopupMenuItem(
          child: Text("Message"),
        ),
      ],
      elevation: 8.0,
    );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
}
