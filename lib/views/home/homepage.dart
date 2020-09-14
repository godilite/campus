import 'package:camp/views/home/components/ItemWidget.dart';
import 'package:camp/views/home/following.dart';
import 'package:camp/views/layouts/drawer_scaffold.dart';
import 'package:camp/views/styles.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  ScrollController _controller = ScrollController();
  ScrollController _gridController = ScrollController();
  bool isBottom = false;
  @override
  void initState() {
    super.initState();
    // listener for scroll controller
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        if (_controller.position.pixels == 0) {
          isBottom = false;
          setState(() {});
        } else {
          isBottom = true;
          setState(() {});
        }
      }
    });

    _gridController.addListener(() {
      if (_gridController.position.atEdge) {
        if (_gridController.position.pixels == 0) {
          isBottom = false;
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    void _showModalSheet(context) {
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: context,
          builder: (BuildContext bc) {
            return Container(
              height: _height * 0.45,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50))),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        height: 5,
                        width: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 20,
                    right: 0,
                    child: ListTile(
                        leading: Icon(Icons.music_note),
                        title: Text('Music'),
                        onTap: () => {}),
                  ),
                  Positioned(
                    top: 100,
                    left: 20,
                    right: 0,
                    child: ListTile(
                        leading: Icon(Icons.music_note),
                        title: Text('Music'),
                        onTap: () => {}),
                  ),
                  Positioned(
                    top: 150,
                    left: 20,
                    right: 0,
                    child: ListTile(
                        leading: Icon(Icons.music_note),
                        title: Text('Music'),
                        onTap: () => {}),
                  ),
                  Positioned(
                    top: 200,
                    left: 20,
                    right: 0,
                    child: ListTile(
                        leading: Icon(Icons.music_note),
                        title: Text('Music'),
                        onTap: () => {}),
                  ),
                ],
              ),
            );
          });
    }

    return DrawScaffold('', LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          controller: _controller,
          child: Column(children: [
            Container(
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  Positioned(
                      top: 70,
                      left: 20,
                      child: Container(
                          height: 30,
                          color: Colors.green,
                          width: _width * 0.3)),
                  Positioned(
                      bottom: 10,
                      right: 20,
                      child: Container(
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'See more',
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Icon(
                                FlutterIcons.arrowright_ant,
                                color: Colors.white,
                                size: 20,
                              )
                            ],
                          ),
                          width: _width * 0.3)),
                ],
              ),
              height: _height * 0.35,
              width: _width,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(50),
                      bottomLeft: Radius.circular(50))),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 18.0, right: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                        color: kGrey,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          FlutterIcons.users_faw5s,
                          size: 18,
                          color: Colors.white,
                        ),
                        SizedBox(width: 13),
                        Text('All', style: TextStyle(color: Colors.white))
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => Following())),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            FlutterIcons.users_fea,
                            size: 18,
                          ),
                          Icon(
                            FlutterIcons.check_ant,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text('Following',
                              style: TextStyle(color: Colors.grey))
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showModalSheet(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            FlutterIcons.tune_mdi,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text('Filter', style: TextStyle(color: Colors.grey))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10, top: 20),
              child: StaggeredGridView.count(
                shrinkWrap: true,
                padding: EdgeInsets.all(0),
                controller: _gridController,
                crossAxisCount: 4,
                physics: isBottom
                    ? BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics())
                    : NeverScrollableScrollPhysics(),
                children: [
                  ItemWidget(width: _width),
                  ItemWidget(width: _width),
                  ItemWidget(width: _width),
                  ItemWidget(width: _width),
                  ItemWidget(width: _width),
                ],
                staggeredTiles: const <StaggeredTile>[
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
    ), true);
  }
}
