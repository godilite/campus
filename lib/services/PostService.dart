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
        'timestamp': timestamp
      });
      documentSnapshot = await postReference.doc(postId).get();
    }

    return PostModel.fromData(documentSnapshot);
  }
}
