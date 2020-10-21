import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/models/post_model.dart';
import 'package:camp/models/product_model.dart';
import 'package:camp/views/home/single-item/singleview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:shimmer/shimmer.dart';

class ItemWidget extends StatelessWidget {
  const ItemWidget({Key key, @required Product post, double width})
      : _post = post,
        super(key: key);

  final Product _post;

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    return Material(
      child: Stack(
        fit: StackFit.loose,
        alignment: Alignment.center,
        children: [
          Positioned(
              child: Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Hero(
              tag: _post.id,
              child: InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => SingleView(
                              post: _post,
                            ))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: _post.images.length > 0
                      ? Image(
                          width: _width * 0.45,
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(_post.images[0]),
                        )
                      : Shimmer.fromColors(
                          baseColor: Colors.grey[200],
                          highlightColor: Colors.grey[350],
                          child: Container(
                            width: _width * 0.45,
                            height: 200,
                          ),
                        ),
                ),
              ),
            ),
          )),
          Positioned(
              top: 10,
              right: 20,
              child: InkWell(
                onTap: () => print('Tap'),
                child: Icon(
                  FlutterIcons.favorite_border_mdi,
                  color: Colors.white,
                ),
              )),
          Positioned(
            bottom: 0,
            right: 10,
            child: Container(
              height: 13,
              child: Center(
                  child: Icon(
                CupertinoIcons.ellipsis,
                size: 35,
              )),
            ),
          ),
        ],
      ),
    );
  }
}
