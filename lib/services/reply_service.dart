import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class ReplyService {
  final replyReference = FirebaseFirestore.instance.collection("replies");
  final userReference = FirebaseFirestore.instance.collection("users");
  getReplies(var commentId) {
//    return _combineStream;
  }

  // getMoreComments(var postId, DocumentSnapshot startAfter) async {
  //   Stream<List<CombineStream>> _combineStream;

  //   _combineStream = commentsReference
  //       .doc(postId)
  //       .collection('comments')
  //       .orderBy('timestamp', descending: true)
  //       .limit(10)
  //       .startAfterDocument(startAfter)
  //       .snapshots()
  //       .map((convert) {
  //     return convert.docs.map((f) {
  //       Stream<CommentModel> comments =
  //           Stream.value(f).map<CommentModel>((document) {
  //         startAfter = document;
  //         return CommentModel(
  //           document.get('content') ?? '',
  //           document.get('id') ?? '',
  //           document.get('likes') ?? null,
  //           document.get('likesCount') ?? 0,
  //           document.get('uid') ?? '',
  //           false,
  //           null,
  //           document.get('postId') ?? '',
  //           document.get('timestamp') ?? '',
  //         );
  //       });

  //       Stream<UserAccount> user = userReference
  //           .doc(f.get('uid'))
  //           .snapshots()
  //           .map<UserAccount>((document) => UserAccount.fromData(document));
  //       return Rx.combineLatest2(
  //           comments, user, (comments, user) => CombineStream(comments, user));
  //     });
  //   }).switchMap((observables) {
  //     return observables.length > 0
  //         ? Rx.combineLatestList(observables)
  //         : Stream.value([]);
  //   });

  //   return _combineStream;
  // }

  // postComment(postId, content) {
  //   var id = uuid.v1();
  //   commentsReference.doc(postId).collection('comments').doc(id).set({
  //     'content': content,
  //     'id': id,
  //     'uid': AuthService().auth.currentUser.uid,
  //     'postId': postId,
  //     'likesCount': 0,
  //     'likes': null,
  //     'hasReply': null,
  //     'replies': null,
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });
  // }
}
