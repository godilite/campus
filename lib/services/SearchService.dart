import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  final userReference = FirebaseFirestore.instance.collection("users");

  Future<QuerySnapshot> search(String text) async {
    QuerySnapshot allUsers =
        await userReference.where('name', isGreaterThanOrEqualTo: text).get();

    return allUsers;
  }
}
