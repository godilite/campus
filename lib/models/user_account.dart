class UserAccount {
  final String id;
  final String email;
  final String name;
  final String profileUrl;
  final String phone;
  final String coverPhoto;
  final String password;

  //first stage registration ends here

  UserAccount({
    this.id,
    this.name,
    this.email,
    this.profileUrl,
    this.coverPhoto,
    this.password,
    this.phone,
  });

  factory UserAccount.fromData(Map<String, dynamic> data) {
    return UserAccount(
        id: data['id'],
        name: data['name'],
        email: data['email'],
        profileUrl: data['profileUrl'],
        coverPhoto: data['coverPhoto'],
        password: data['password'],
        phone: data['phone']);
  }
  Map<String, dynamic> toJson() {
    return {
      id: id,
      name: name,
      email: email,
      profileUrl: profileUrl,
      coverPhoto: coverPhoto,
      password: password,
      phone: phone
    }..removeWhere((key, value) => key == null || value == null);
  }
}
