import 'package:cached_network_image/cached_network_image.dart';
import 'package:camp/models/activity_model.dart';
import 'package:camp/models/user_account.dart';
import 'package:camp/service_locator.dart';
import 'package:camp/services/CommentService.dart';
import 'package:camp/services/PostService.dart';
import 'package:camp/services/UserService.dart';
import 'package:camp/views/home/single-item/comment.dart';
import 'package:camp/views/messaging/widgets/full_photo.dart';
import 'package:camp/views/post/widgets/watermark.dart';
import 'package:camp/views/profile/profile.dart';
import 'package:camp/views/styles.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:like_button/like_button.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SingleView extends StatefulWidget {
  final Datum post;
  final bool liked;
  const SingleView({Key key, @required this.post, @required this.liked})
      : super(key: key);
  @override
  _SingleViewState createState() => _SingleViewState(liked: liked);
}

class _SingleViewState extends State<SingleView> {
  _SingleViewState({@required this.liked});
  PostService _postService = locator<PostService>();
  bool liked = false;
  int _current = 0;
  final List<String> images = [];
  var _tapPosition;

  UserService userService = locator<UserService>();
  CommentService commentService = locator<CommentService>();
  UserAccount user;
  int commentCount = 0;
  BehaviorSubject<List<DocumentSnapshot>> postController;
  Future<bool> _likePost(liked) async {
    setState(() {
      liked = !liked;
    });
    await _postService.likePost(widget.post.details.product.id);
    return liked;
  }

  Future<bool> _sharePost(share) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Watermark(url: images[_current], post: widget.post),
      ),
    );
    return true;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.post.details.product.images.forEach((file) {
        images.add(file);
      });
      images.forEach((imageUrl) {
        precacheImage(CachedNetworkImageProvider(imageUrl), context);
      });
      postUser();
      setState(() {});
    });
    fetch();
    postController = BehaviorSubject<List<DocumentSnapshot>>();
    super.initState();
  }

  Stream<List<DocumentSnapshot>> get postStream => postController.stream;
  postUser() async {
    user = await userService.user(widget.post.user.id);
    setState(() {});
  }

  fetch() async {
    int items =
        await commentService.getCommentsCount(widget.post.details.product.id);
    setState(() {
      commentCount = items;
    });
  }

  relatedPosts() async {
    // List<DocumentSnapshot> related =
    //     await _postService.searchPosts(widget.post.keywords);
    // setState(() {
    //   postController.sink.add(related);
//    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                size: 20, color: Colors.grey.shade500),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            GestureDetector(
              onTapDown: _storePosition,
              onTap: () {
                _showMenu();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(CupertinoIcons.ellipsis,
                    size: 25, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: images.length > 0
                      ? Column(children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40),
                                topLeft: Radius.circular(40),
                              ),
                              color: Colors.white,
                            ),
                            child: Stack(
                              children: [
                                CarouselSlider.builder(
                                  options: CarouselOptions(
                                      autoPlay: false,
                                      height: viewportConstraints.maxWidth,
                                      viewportFraction: 1,
                                      enableInfiniteScroll: false,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          _current = index;
                                        });
                                      }),
                                  itemCount: images.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FullPhoto(url: images[index]),
                                        ),
                                      ),
                                      child: Image(
                                          image: CachedNetworkImageProvider(
                                              images[index]),
                                          fit: BoxFit.fitWidth),
                                    );
                                  },
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: images.map((url) {
                                      int index = images.indexOf(url);
                                      return Container(
                                        width: 5.0,
                                        height: 5.0,
                                        margin: EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 2.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _current == index
                                              ? Color.fromRGBO(0, 0, 0, 0.9)
                                              : Color.fromRGBO(0, 0, 0, 0.4),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 3),
                                    color: Colors.grey.shade200,
                                    blurRadius: 5)
                              ],
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(40),
                                bottomLeft: Radius.circular(40),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading:
                                      user != null && user.profileUrl != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              child: CachedNetworkImage(
                                                placeholder: (context, url) =>
                                                    Container(
                                                  child: Icon(
                                                    Icons.account_circle,
                                                    size: 40.0,
                                                    color: kGrey,
                                                  ),
                                                  width: 40.0,
                                                  height: 40.0,
                                                  padding: EdgeInsets.all(0.0),
                                                ),
                                                imageUrl: user.profileUrl,
                                                width: 40.0,
                                                height: 40.0,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Icon(
                                              Icons.account_circle,
                                              size: 50.0,
                                              color: kGrey,
                                            ),
                                  title: Padding(
                                    padding: EdgeInsets.only(top: 15.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text('From',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12)),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: InkWell(
                                            onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfilePage(
                                                  user: widget.post.user,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              widget.post.user.name,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Flexible(
                                            flex: 4,
                                            child: LikeButton(
                                              countPostion: CountPostion.bottom,
                                              onTap: _likePost,
                                              isLiked: liked,
                                              size: 30,
                                              circleColor: CircleColor(
                                                  start: Color(0xffFAB7fc),
                                                  end: Color(0xffFAB70A)),
                                              bubblesColor: BubblesColor(
                                                dotPrimaryColor:
                                                    Color(0xffccff0A),
                                                dotSecondaryColor:
                                                    Color(0xffFAB70A),
                                              ),
                                              likeBuilder: (bool liked) {
                                                return liked
                                                    ? Icon(
                                                        Icons.favorite,
                                                        color: Colors.red,
                                                        size: 20,
                                                      )
                                                    : Icon(
                                                        Icons.favorite_outline,
                                                        color: Colors.grey,
                                                        size: 20,
                                                      );
                                              },
                                              likeCount: widget.post.details
                                                  .productLikes.length,
                                              countBuilder: (int count,
                                                  bool liked, String text) {
                                                var color = liked
                                                    ? Colors.red
                                                    : Colors.grey;
                                                Widget result;
                                                if (count == 0) {
                                                  result = Text(
                                                    "",
                                                    style:
                                                        TextStyle(color: color),
                                                  );
                                                } else
                                                  result = Text(
                                                    text,
                                                    style:
                                                        TextStyle(color: color),
                                                  );
                                                return result;
                                              },
                                            ),
                                          ),
                                          Flexible(
                                            flex: 4,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10.0),
                                              child: LikeButton(
                                                onTap: _sharePost,
                                                size: 20,
                                                circleColor: CircleColor(
                                                    start: Color(0xffFAB7fc),
                                                    end: Color(0xffFAB70A)),
                                                bubblesColor: BubblesColor(
                                                  dotPrimaryColor:
                                                      Color(0xffccff0A),
                                                  dotSecondaryColor:
                                                      Color(0xffFAB70A),
                                                ),
                                                likeBuilder: (bool liked) {
                                                  return Icon(
                                                    FlutterIcons.share_sli,
                                                    color: liked
                                                        ? Colors.grey
                                                        : Colors.grey,
                                                    size: 16,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 4,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10.0),
                                              child: LikeButton(
                                                onTap: _likePost,
                                                size: 25,
                                                circleColor: CircleColor(
                                                    start: Color(0xffFAB7fc),
                                                    end: Color(0xffFAB70A)),
                                                bubblesColor: BubblesColor(
                                                  dotPrimaryColor:
                                                      Color(0xffccff0A),
                                                  dotSecondaryColor:
                                                      Color(0xffFAB70A),
                                                ),
                                                likeBuilder: (bool saved) {
                                                  return saved
                                                      ? Icon(
                                                          CupertinoIcons
                                                              .bookmark_fill,
                                                          color: kYellow,
                                                          size: 20,
                                                        )
                                                      : Icon(
                                                          CupertinoIcons
                                                              .bookmark,
                                                          color: Colors.grey,
                                                          size: 20,
                                                        );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      width:
                                          viewportConstraints.maxWidth * 0.3),
                                  subtitle: RatingBar(
                                    initialRating: 3,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 10,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 0.02),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Visibility(
                                              visible: widget.post.details
                                                          .product.isForsale ==
                                                      1
                                                  ? true
                                                  : false,
                                              child: Text(
                                                widget
                                                    .post.details.product.title,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            Visibility(
                                              visible: widget.post.details
                                                          .product.isForsale ==
                                                      1
                                                  ? true
                                                  : false,
                                              child: SizedBox(
                                                height: 10,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: 30.0,
                                                  top: 10,
                                                  bottom: 10),
                                              child: Text(
                                                widget.post.details.product
                                                    .content,
                                                style: TextStyle(fontSize: 13),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: widget.post.details.product
                                                    .isForsale ==
                                                1
                                            ? true
                                            : false,
                                        child: Container(
                                          height: 100,
                                          color: Colors.grey,
                                          width: 0.5,
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Visibility(
                                            visible: widget.post.details.product
                                                        .isForsale ==
                                                    1
                                                ? true
                                                : false,
                                            child: Text(
                                              '₦ ${widget.post.details.product.amount}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 20.0, right: 20, bottom: 0),
                              child: InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Comment(
                                              postId: widget
                                                  .post.details.product.id,
                                            ))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    widget.post.details.comments.length == 0
                                        ? Text(
                                            'Be the first to comment',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          )
                                        : Text(
                                            'View $commentCount ${commentCount > 1 ? 'comments' : 'comment'}',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                    Icon(
                                      CupertinoIcons.chat_bubble,
                                      color: kText,
                                      size: 20,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          widget.post.details.comments.length > 0
                              ? Column(
                                  children: widget.post.details.comments
                                      .map(
                                        (e) => ListTile(
                                          contentPadding: EdgeInsets.only(
                                              left: 10, right: 10),
                                          leading: e.user.profileUrl == null
                                              ? Icon(Icons.account_circle,
                                                  size: 40)
                                              : CircleAvatar(
                                                  backgroundColor: kYellow,
                                                  backgroundImage:
                                                      CachedNetworkImageProvider(
                                                          e.user.profileUrl),
                                                  radius: 20,
                                                ),
                                          title: Text(
                                            e.user.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                            e.comment,
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      )
                                      .toList())
                              : Container(
                                  height: 20,
                                ),
                          SizedBox(height: 10),
                          Text(
                            'Related Posts',
                            style: TextStyle(fontSize: 14),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 10.0, right: 10, top: 20),
                              child: suggestedBuilder()),
                        ])
                      : Center(
                          child: Text('loading..'),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
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
          child: Text("Report post"),
        ),
        PopupMenuItem(
          child: Text("Hide"),
        ),
        PopupMenuItem(
          child: Text("Delete"),
        ),
      ],
      elevation: 8.0,
    );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  StreamBuilder<List<DocumentSnapshot>> suggestedBuilder() {
    return StreamBuilder<List<DocumentSnapshot>>(
        stream: postStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StaggeredGridView.count(
              crossAxisCount: 4,
              children: snapshot.data.map((DocumentSnapshot post) {
                return Container(); //ItemWidget(post: PostModel.fromData(post));
              }).toList(),
              staggeredTiles: snapshot.data
                  .map<StaggeredTile>((_) => StaggeredTile.fit(2))
                  .toList(),
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
            );
          }
          return Container(
            child: Padding(
              padding: EdgeInsets.all(38.0),
              child: Center(
                  child: Text(
                'No similar item(s) found',
                style: TextStyle(color: kGrey),
              )),
            ),
          );
        });
  }

  void dispose() {
    super.dispose();
    postController.close();
  }
}
