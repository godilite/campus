import 'package:camp/views/layouts/drawer_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../styles.dart';

class Sponsored extends StatefulWidget {
  @override
  _SponsoredState createState() => _SponsoredState();
}

class _SponsoredState extends State<Sponsored> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  int currentItem = 0;
  int min = 0;
  int max = 2;
  @override
  void initState() {
    positions();
    super.initState();
  }

  void positions() {
    itemPositionsListener.itemPositions.addListener(() {
      Iterable<ItemPosition> positions =
          itemPositionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        // Determine the first visible item by finding the item with the
        // smallest trailing edge that is greater than 0.  i.e. the first
        // item whose trailing edge in visible in the viewport.
        min = positions
            .where((ItemPosition position) => position.itemTrailingEdge > 0)
            .reduce((ItemPosition min, ItemPosition position) =>
                position.itemTrailingEdge < min.itemTrailingEdge
                    ? position
                    : min)
            .index;
        // Determine the last visible item by finding the item with the
        // greatest leading edge that is less than 1.  i.e. the last
        // item whose leading edge in visible in the viewport.
        max = positions
            .where((ItemPosition position) => position.itemLeadingEdge < 1)
            .reduce((ItemPosition max, ItemPosition position) =>
                position.itemLeadingEdge > max.itemLeadingEdge ? position : max)
            .index;
        setState(() {});
      }
    });
  }

  Color _color = Colors.green;
  BorderRadiusGeometry _borderRadius = BorderRadius.circular(8);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return CustomScrollView(slivers: [
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    child: sponsoredStack(viewportConstraints),
                    height: viewportConstraints.maxHeight,
                    width: viewportConstraints.maxWidth,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200))),
                  ),
                ]),
              ),
            ]);
          },
        ));
  }

  Stack sponsoredStack(BoxConstraints viewportConstraints) {
    return Stack(fit: StackFit.passthrough, children: [
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          height: viewportConstraints.maxHeight * 0.5,
          decoration: BoxDecoration(
              // image: DecorationImage(
              //   image: widget.user != null && widget.user.coverPhoto != null
              //       ? CachedNetworkImageProvider(widget.user.coverPhoto)
              //       : AssetImage('assets/img_not_available.jpeg'),
              //   fit: BoxFit.cover,
              // ),
              color: kYellow,
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30))),
        ),
      ),
      Positioned(
        bottom: 0,
        right: 10,
        left: 10,
        height: viewportConstraints.maxHeight * 0.45,
        child: Text('New Shoe',
            style: TextStyle(
                color: kText, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      Positioned(
        bottom: 0,
        right: 10,
        left: 10,
        height: viewportConstraints.maxHeight * 0.40,
        child: Text(
          'New descript da of the sho oua jsd just mana anuse asdsj pwjomass las sdu ,msad udbs asjbwdj ',
          style: TextStyle(color: kGrey),
        ),
      ),
      Positioned(
        top: 0,
        right: 10,
        left: 10,
        bottom: 60,
        child: ScrollablePositionedList.builder(
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionsListener,
            scrollDirection: Axis.horizontal,
            itemCount: 29,
            itemBuilder: (context, index) {
              currentItem = index;
              return Container(
                margin: EdgeInsets.all(4),
                height: viewportConstraints.maxHeight * 0.2,
                width: viewportConstraints.maxWidth * 0.56,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    Positioned(
                      bottom: 0,
                      child: AnimatedContainer(
                        // Use the properties stored in the State class.
                        width: index > min && index < max
                            ? viewportConstraints.maxWidth * 0.56
                            : viewportConstraints.maxWidth * 0.56,

                        height: index > min && index < max
                            ? viewportConstraints.maxHeight * 0.2
                            : viewportConstraints.maxHeight * 0.17,
                        decoration: BoxDecoration(
                          color: _color,
                          borderRadius: _borderRadius,
                        ),
                        // Define how long the animation should take.
                        duration: Duration(seconds: 1),
                        // Provide an optional curve to make the animation feel smoother.
                        curve: Curves.fastOutSlowIn,
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
      Positioned(
        bottom: 20,
        right: 10,
        child: Text(
          'Visit Page >>',
          style: TextStyle(color: kGrey),
        ),
      ),
    ]);
  }
}
