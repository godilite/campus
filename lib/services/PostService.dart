import 'package:camp/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class PostService {
  FirebaseAuth auth = FirebaseAuth.instance;
  final postReference = FirebaseFirestore.instance.collection("posts");
  final userReference = FirebaseFirestore.instance.collection("users");
  final DateTime timestamp = DateTime.now();

  Future post(PostModel post) async {
    var postId = uuid.v1();
    DocumentSnapshot documentSnapshot = await postReference.doc(postId).get();
    DocumentSnapshot userSnapshot =
        await userReference.doc(auth.currentUser.uid).get();
    if (!documentSnapshot.exists) {
      postReference.doc(postId).set({
        'id': postId,
        'title': post.title ?? '',
        'author': userSnapshot.get('name') ?? '',
        'userId': userSnapshot.get('id') ?? '',
        'files': post.files ?? '',
        'hashtags': post.hashtags ?? '',
        'content': post.content ?? '',
        'commentCount': 0,
        'likesCount': 0,
        'likes': '',
        'amount': post.amount ?? 0.0,
        'forSale': post.forSale ?? false,
        'location': post.location ?? '',
        'lat': post.lat ?? '',
        'long': post.long ?? '',
        'keywords': post.title != null
            ? post.title.split(' ')
            : post.content.split(' '),
        'timestamp': timestamp
      });
      documentSnapshot = await postReference.doc(postId).get();
    }

    return PostModel.fromData(documentSnapshot);
  }

  likePost(postId) {
    postReference.doc(postId).update({
      'likes': FieldValue.arrayUnion(['${auth.currentUser.uid}'])
    });
  }

  Future<List<DocumentSnapshot>> getPosts() async {
    List<DocumentSnapshot> documentList;
    documentList = (await postReference
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get())
        .docs;
    return documentList;
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
}
