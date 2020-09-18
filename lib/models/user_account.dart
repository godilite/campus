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

  UserAccount({
    this.id,
    this.name,
    this.email,
    this.profileUrl,
    this.coverPhoto,
    this.username,
    this.phone,
    this.bio,
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
        bio: data.get('bio'));
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
      bio: bio
    }..removeWhere((key, value) => key == null || value == null);
  }
}
