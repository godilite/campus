import 'package:camp/models/user_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final userReference = FirebaseFirestore.instance.collection("users");

  Future<UserAccount> user(String id) async {
    DocumentSnapshot documentSnapshot = await userReference.doc(id).get();
    UserAccount user = UserAccount.fromData(documentSnapshot);
    return user;
  }
}
