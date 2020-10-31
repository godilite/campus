class UserAccount {
  UserAccount({
    this.id,
    this.name,
    this.username,
    this.email,
    this.emailVerifiedAt,
    this.bio,
    this.phone,
    this.profileUrl,
    this.coverPhoto,
    this.uid,
    this.userType,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.long,
    this.lat,
  });

  int id;
  String name;
  String username;
  String email;
  dynamic emailVerifiedAt;
  dynamic bio;
  String phone;
  String profileUrl;
  dynamic coverPhoto;
  String uid;
  String userType;
  String address;
  DateTime createdAt;
  DateTime updatedAt;
  double long;
  double lat;

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
        id: json["id"],
        name: json["name"],
        username: json["username"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        bio: json["bio"],
        phone: json["phone"],
        profileUrl: json["profileUrl"],
        coverPhoto: json["coverPhoto"],
        uid: json["uid"],
        userType: json["user_type"],
        address: json["address"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        long: double.parse(json["long"]),
        lat: double.parse(json["lat"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": username,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "bio": bio,
        "phone": phone,
        "profileUrl": profileUrl,
        "coverPhoto": coverPhoto,
        "uid": uid,
        "user_type": userType,
        "address": address,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "long": long,
        "lat": lat,
      };
}
