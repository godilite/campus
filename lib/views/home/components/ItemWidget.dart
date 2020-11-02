import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/helpers.dart';
import 'package:camp/models/activity_model.dart';
import 'package:camp/models/product_like.dart';
import 'package:camp/services/PostService.dart';
import 'package:camp/views/home/single-item/singleview.dart';
import 'package:camp/views/profile/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:like_button/like_button.dart';

import '../../../service_locator.dart';

class ItemWidget extends StatefulWidget {
  const ItemWidget({Key key, @required Datum post, double width})
      : _post = post,
        super(key: key);

  final Datum _post;

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int _userId;
  PostService _postService = locator<PostService>();
  @override
  void initState() {
    _currentUser();
    super.initState();
  }

  bool liked = false;
  _currentUser() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _userId = prefs.getInt('userId');
    });
  }

  Future<bool> _likePost(liked) async {
    setState(() {
      liked = !liked;
    });

    await _postService.likePost(widget._post.details.product.id);
    return liked;
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    var like = widget._post.details.productLikes
        .where((ProductLike element) => element.userId == _userId);
    // ignore: unnecessary_statements
    like.isNotEmpty ? liked = true : null;
    return Material(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _showModalSheet(context, _height, widget._post, _width);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Stack(
            fit: StackFit.loose,
            alignment: Alignment.center,
            children: [
              Positioned(
                  child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          SingleView(post: widget._post, liked: liked),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: widget._post.details.product.images.length > 0
                        ? CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[200],
                                highlightColor: Colors.grey[350],
                                child: Container(
                                  width: _width * 0.45,
                                  height: 200,
                                ),
                              ),
                            ),
                            imageUrl: widget._post.details.product.images[0],
                            fit: BoxFit.cover,
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
              )),
              Positioned(
                bottom: 0,
                right: 10,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    height: 13,
                    child: Icon(
                      CupertinoIcons.ellipsis,
                      size: 30,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: LikeButton(
                  onTap: _likePost,
                  isLiked: liked,
                  size: 30,
                  circleColor: CircleColor(
                      start: Color(0xffFAB7fc), end: Color(0xffFAB70A)),
                  bubblesColor: BubblesColor(
                    dotPrimaryColor: Color(0xffccff0A),
                    dotSecondaryColor: Color(0xffFAB70A),
                  ),
                  likeBuilder: (bool liked) {
                    return Icon(
                      Icons.favorite,
                      color: liked ? Colors.red : Colors.grey,
                      size: 20,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Filter modalsheet
void _showModalSheet(context, double height, Datum post, _width) {
  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bc) {
        return Container(
          height: height * 0.45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
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
                top: 15,
                left: _width * 0.20,
                right: _width * 0.20,
                child: Center(
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8),
                    leading: CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(post.user.profileUrl),
                    ),
                    title: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                        truncate(30, post.user.name),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    subtitle: RatingBar(
                      initialRating: 3,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 15,
                      itemPadding: EdgeInsets.symmetric(horizontal: 0.02),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 90,
                right: 0,
                left: 0,
                child: Divider(),
              ),
              Positioned(
                top: 90,
                left: 0,
                right: 0,
                child: ListTile(
                  title: Text(
                    post.details.product.title.isEmpty
                        ? truncate(50, post.details.product.content)
                        : truncate(50, post.details.product.title),
                  ),
                  trailing: Text(
                    '₦ ${post.details.product.amount}',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: ListTile(
                    leading: Icon(Icons.add_to_photos_outlined),
                    title: Text('See similar Items'),
                    dense: true,
                    onTap: () => {}),
              ),
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: ListTile(
                    leading: Icon(Icons.share_outlined),
                    title: Text('Share'),
                    dense: true,
                    onTap: () => {}),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: ListTile(
                  leading: Icon(CupertinoIcons.archivebox),
                  dense: true,
                  title: Text('Visit page'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ProfilePage(
                        user: post.user,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}
