import 'package:camp/models/user_account.dart';
import 'package:camp/streams/combine_followers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class UserService {
  FirebaseFirestore rootRef = FirebaseFirestore.instance;
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
  follow(String uid) async {
    CollectionReference followingReference = rootRef
        .collection("following/" + auth.currentUser.uid + "/userFollowing");
    CollectionReference followersReference =
        rootRef.collection("followers/" + uid + "/userFollower");

    var data = await followersReference
        .where('uid', isEqualTo: auth.currentUser.uid)
        .get();
    if (data.size > 0) return true;
    if (data.size == 0)
      try {
        followersReference.add({'uid': auth.currentUser.uid});
        userReference.doc(uid).update({'followers': FieldValue.increment(1)});
      } catch (e) {
        print(e);
      }
    try {
      followingReference.add({'uid': uid});
      userReference
          .doc(auth.currentUser.uid)
          .update({'following': FieldValue.increment(1)});
    } catch (e) {
      print(e);
    }
    return true;
  }

  Future<bool> isFollowing(String uid) async {
    CollectionReference followersReference =
        rootRef.collection("followers/" + uid + "/userFollower");

    var data = await followersReference
        .where('uid', isEqualTo: auth.currentUser.uid)
        .get();
    return data.size > 0 ? true : false;
  }

  unfollow(String uid) async {
    CollectionReference followingReference = rootRef
        .collection("following/" + auth.currentUser.uid + "/userFollowing");
    CollectionReference followersReference =
        rootRef.collection("followers/" + uid + "/userFollower");
    var datafollowing =
        await followingReference.where('uid', isEqualTo: uid).get();
    var data = await followersReference
        .where('uid', isEqualTo: auth.currentUser.uid)
        .get();
    if (data.size > 0)
      try {
        followersReference.doc(data.docs.first.id).delete();
        userReference.doc(uid).update({'followers': FieldValue.increment(-1)});
      } catch (e) {
        print(e);
      }
    try {
      followingReference.doc(datafollowing.docs.first.id).delete();
      userReference
          .doc(auth.currentUser.uid)
          .update({'following': FieldValue.increment(-1)});
    } catch (e) {
      print(e);
    }
    return true;
  }

  getFollowers(String uid) {
    CollectionReference followersReference =
        rootRef.collection("followers/" + uid + "/userFollower");
    Stream<List<CombineFollowers>> _combineStream;

    _combineStream = followersReference.snapshots().map((convert) {
      return convert.docs.map((f) {
        Stream<UserAccount> userIds =
            Stream.value(f).map<UserAccount>((document) {
          return UserAccount(id: document.get('uid') ?? '');
        });

        Stream<UserAccount> user = userReference
            .doc(f.get('uid'))
            .snapshots()
            .map<UserAccount>((document) => UserAccount.fromData(document));
        return Rx.combineLatest2(
            userIds, user, (userIds, user) => CombineFollowers(userIds, user));
      });
    }).switchMap((observables) {
      return observables.length > 0
          ? Rx.combineLatestList(observables)
          : Stream.value([]);
    });

    return _combineStream;
  }

  getFollowing(String uid) {
    CollectionReference followersReference =
        rootRef.collection("following/" + uid + "/userFollowing");
    Stream<List<CombineFollowers>> _combineStream;

    _combineStream = followersReference.snapshots().map((convert) {
      return convert.docs.map((f) {
        Stream<UserAccount> users =
            Stream.value(f).map<UserAccount>((document) {
          return UserAccount(
            id: document.get('uid') ?? '',
          );
        });

        Stream<UserAccount> user = userReference
            .doc(f.get('uid'))
            .snapshots()
            .map<UserAccount>((document) => UserAccount.fromData(document));
        return Rx.combineLatest2(
            users, user, (users, user) => CombineFollowers(users, user));
      });
    }).switchMap((observables) {
      return observables.length > 0
          ? Rx.combineLatestList(observables)
          : Stream.value([]);
    });

    return _combineStream;
  }
}
