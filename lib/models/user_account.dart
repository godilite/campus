import 'package:cloud_firestore/cloud_firestore.dart';

class UserAccount {
  final String id;
  final String email;
  final String name;
  final String profileUrl;
  final String phone;
  final String coverPhoto;
  final String username;
  final String bio;
  final String address;
  final String long;
  final String lat;
  final int postCount;
  final String rating;
  final List ratingList;
  final List followers;
  final List following;
  UserAccount({
    this.id,
    this.name,
    this.email,
    this.profileUrl,
    this.coverPhoto,
    this.username,
    this.phone,
    this.bio,
    this.address,
    this.long,
    this.lat,
    this.postCount,
    this.rating,
    this.ratingList,
    this.followers,
    this.following,
  });

  factory UserAccount.fromData(DocumentSnapshot data) {
    return UserAccount(
      id: data.id,
      name: data.get('name'),
      email: data.get('email'),
      profileUrl: data.get('profileUrl'),
      coverPhoto: data.get('coverPhoto'),
      username: data.get('username'),
      phone: data.get('phone'),
      bio: data.get('bio'),
      address: data.get('address'),
      long: data.get('long'),
      lat: data.get('lat'),
      postCount: data.get('postCount'),
      rating: data.get('rating'),
      ratingList: data.get('ratingList'),
      followers: data.get('followers'),
      following: data.get('following'),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      id: id,
      name: name,
      email: email,
      profileUrl: profileUrl,
      coverPhoto: coverPhoto,
      username: username,
      phone: phone,
      bio: bio,
      address: address,
      long: long,
      lat: lat
    }..removeWhere((key, value) => key == null || value == null);
  }
}
