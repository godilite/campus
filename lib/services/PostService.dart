import 'package:camp/models/activity_model.dart';
import 'package:camp/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class PostService {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Dio dio = new Dio();
  FirebaseAuth auth = FirebaseAuth.instance;
  final rootRef = FirebaseFirestore.instance;
  final postReference = FirebaseFirestore.instance.collection("posts");
  final userReference = FirebaseFirestore.instance.collection("users");
  final DateTime timestamp = DateTime.now();

  Future post(PostModel post) async {
    var postId = uuid.v1();
    DocumentSnapshot documentSnapshot;

    storePostOnBackup(post);

    postReference.doc(postId).set({
      'id': postId,
      'title': post.title ?? '',
      'files': post.files ?? '',
      'hashtags': post.hashtags ?? '',
      'content': post.content ?? '',
      'amount': post.amount ?? 0.0,
      'forSale': post.forSale ?? false,
      'location': post.location ?? '',
      'lat': post.lat ?? '',
      'long': post.long ?? '',
      'timestamp': timestamp
    });
    documentSnapshot = await postReference.doc(postId).get();

    return PostModel.fromData(documentSnapshot);
  }

  likePost(postId) {
    postReference.doc(postId).update({
      'likes': FieldValue.arrayUnion(['${auth.currentUser.uid}'])
    });
  }

  Future<Activity> getPosts() async {
    final SharedPreferences prefs = await _prefs;
    Activity activity;
    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";

    try {
      response = await dio.get("http://10.0.2.2:8000/api/v1/general/activities",
          queryParameters: {"page": 1});
      activity = Activity.fromJson(response.data);
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.error != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }
    }

    return activity;
  }

  Future<List<DocumentSnapshot>> loadMorePosts(
      DocumentSnapshot startAfter) async {
    List<DocumentSnapshot> documentList;
    documentList = (await postReference
            .orderBy('timestamp', descending: true)
            .limit(10)
            .startAfterDocument(startAfter)
            .get())
        .docs;

    return documentList;
  }

  Future<List<DocumentSnapshot>> searchPosts(List words) async {
    List<DocumentSnapshot> documentList;
    documentList = (await postReference
            .orderBy('timestamp', descending: true)
            .limit(10)
            .where('keywords', arrayContainsAny: words.take(10))
            .get())
        .docs;

    return documentList;
  }

  Future<List<DocumentSnapshot>> getUserPosts(String uid) async {
    List<DocumentSnapshot> documentList;
    documentList = (await postReference
            .where('userId', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get())
        .docs;
    return documentList;
  }

  Future<List<DocumentSnapshot>> getUserFrendsPosts() async {
    List friendsId = [];
    List<DocumentSnapshot> postByFriends;
    CollectionReference followingReference = rootRef
        .collection("following/" + auth.currentUser.uid + "/userFollowing");
    //GET user friends
    List<DocumentSnapshot> documentList;

    documentList = (await followingReference.get()).docs;

    documentList.forEach((element) {
      friendsId.add(element.get('uid'));
    });

    List<DocumentSnapshot> postList;
    postList = (await postReference
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get())
        .docs;
    postList.forEach((element) {
      if (friendsId.contains(element.get('userId'))) postByFriends.add(element);
    });

    return postByFriends;
    //Find their post
  }

  addCount() {
    userReference
        .doc(auth.currentUser.uid)
        .update({'postCount': FieldValue.increment(1)});
  }

  storePostOnBackup(PostModel post) async {
    final SharedPreferences prefs = await _prefs;
    Response response;
    var token = prefs.getString('token');
    dio.options.headers['content-Type'] = 'application/json';
    dio.options.headers["authorization"] = "Bearer $token";

    try {
      response = await dio.post("http://10.0.2.2:8000/api/v1/upload", data: {
        'title': post.title ?? '',
        'images': post.images ?? '',
        'hashtags': post.hashtags ?? '',
        'content': post.content ?? '',
        'amount': post.amount ?? 0.0,
        'forSale': post.forSale ?? false,
        'location': post.location ?? '',
        'latitude': post.lat ?? '',
        'longitude': post.long ?? '',
      });
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.error != null) {
        print(e.response.data);
        print(e.response.headers);
        print(e.response.request);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print(e.request);
        print(e.message);
      }
    }
    print(response);
  }
}
