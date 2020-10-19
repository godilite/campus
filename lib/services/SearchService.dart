import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../helpers.dart';

class SearchService {
  final userReference = FirebaseFirestore.instance.collection("users");
  final postReference = FirebaseFirestore.instance.collection("posts");

  Future<Stream<List<QuerySnapshot>>> search(String text) async {
    Stream<QuerySnapshot> _userStream;
    Stream<QuerySnapshot> _postStream;

    _userStream =
        userReference.where('name', isGreaterThanOrEqualTo: text).snapshots();
    List keywords = searchKeyword(text);
    _postStream = postReference
        .orderBy('timestamp', descending: true)
        .limit(10)
        .where('keywords', arrayContainsAny: keywords.take(10).toList())
        .snapshots();

    return CombineLatestStream.list([_userStream, _postStream])
        .asBroadcastStream();
  }

  Future<List<DocumentSnapshot>> searchPosts(words) async {
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
