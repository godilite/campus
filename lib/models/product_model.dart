class Product {
  Product({
    this.id,
    this.title,
    this.location,
    this.amount,
    this.longitude,
    this.latitude,
    this.isForsale,
    this.images,
    this.content,
    this.hashtags,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  String title;
  String location;
  String amount;
  dynamic longitude;
  dynamic latitude;
  int isForsale;
  List<dynamic> images;
  String content;
  List<String> hashtags;
  int userId;
  DateTime createdAt;
  DateTime updatedAt;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        title: json["title"],
        location: json["location"],
        amount: json["amount"],
        longitude: json["longitude"],
        latitude: json["latitude"],
        isForsale: json["is_forsale"],
        images: List<dynamic>.from(json["images"].map((x) => x)),
        content: json["content"] == null ? null : json["content"],
        hashtags: List<String>.from(json["hashtags"].map((x) => x)),
        userId: json["user_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "location": location,
        "amount": amount,
        "longitude": longitude,
        "latitude": latitude,
        "is_forsale": isForsale,
        "images": List<dynamic>.from(images.map((x) => x)),
        "content": content == null ? null : content,
        "hashtags": List<dynamic>.from(hashtags.map((x) => x)),
        "user_id": userId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
