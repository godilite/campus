import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  final userReference = FirebaseFirestore.instance.collection("users");

  Future<QuerySnapshot> search(String text) {
    Future<QuerySnapshot> allUsers =
        userReference.where('name', isGreaterThanOrEqualTo: text).get();

    return allUsers;
  }
}
