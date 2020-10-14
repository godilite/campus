import 'package:camp/models/user_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final userReference = FirebaseFirestore.instance.collection("users");
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<UserAccount> user(String id) async {
    DocumentSnapshot documentSnapshot = await userReference.doc(id).get();
    UserAccount user = UserAccount.fromData(documentSnapshot);
    return user;
  }

  ///Follow user function
  ///This function will take the user id parameter and add this
  /// Id to the auth user following, also adds the auth user to the followers
  ///  list of the given user
  follow(String uid) {
    try {
      userReference.doc(auth.currentUser.uid).update({
        'following': FieldValue.arrayUnion([uid])
      });
    } catch (e) {
      print(e);
    }
    try {
      userReference.doc(uid).update({
        'followers': FieldValue.arrayUnion([auth.currentUser.uid])
      });
    } catch (e) {
      print(e);
    }
  }
}
