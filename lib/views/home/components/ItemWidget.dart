import 'package:camp/views/home/single-item/singleview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shimmer/shimmer.dart';

class ItemWidget extends StatelessWidget {
  const ItemWidget({Key key, @required var post, double width})
      : _post = post,
        super(key: key);

  final _post;

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    print(_post);
    return Shimmer.fromColors(
      baseColor: Colors.grey[200],
      highlightColor: Colors.grey[350],
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned(
              child: Card(
            elevation: 8.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Hero(
              tag: _post['id'],
              child: InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => SingleView())),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: FadeInImage(
                    width: _width * 0.45,
                    fit: BoxFit.cover,
                    image: NetworkImage(_post['files'][0]),
                    placeholder: AssetImage(
                        "assets/6181e48ceed63c198f7c787dbfc4fc48.jpg"),
                  ),
                ),
              ),
            ),
          )),
          Positioned(
              top: 10,
              right: 10,
              child: InkWell(
                onTap: () => print('Tap'),
                child: Icon(
                  FlutterIcons.favorite_border_mdi,
                  color: Colors.white,
                ),
              )),
          Positioned(
            bottom: 20,
            left: 30,
            right: 30,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(20)),
              child: Text("$_post['content']"),
            ),
          ),
        ],
      ),
    );
  }
}
