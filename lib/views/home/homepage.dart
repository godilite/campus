import 'package:camp/views/home/components/ItemWidget.dart';
import 'package:camp/views/home/following.dart';
import 'package:camp/views/layouts/drawer_scaffold.dart';
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
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          FlutterIcons.users_faw5s,
                          size: 18,
                        ),
                        SizedBox(width: 13),
                        Text('All', style: TextStyle(color: Colors.white))
                      ],
                    ),
                  ),
                  Container(
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
                        GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Following())),
                            child: Text('Following',
                                style: TextStyle(color: Colors.grey)))
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          FlutterIcons.equalizer_sli,
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        Text('Filter', style: TextStyle(color: Colors.grey))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 18.0, right: 18, top: 20),
              child: Container(
                height: viewportConstraints.maxHeight,
                child: StaggeredGridView.count(
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
            ),
          ]),
        );
      },
    ), true);
  }
}
