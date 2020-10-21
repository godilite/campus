import 'package:camp/models/user_account.dart';

class Comment {
  Comment({
    this.id,
    this.comment,
    this.productId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.likesCount,
    this.repliesCount,
    this.replies,
    this.likes,
    this.user,
  });

  int id;
  String comment;
  int productId;
  int userId;
  DateTime createdAt;
  DateTime updatedAt;
  int likesCount;
  int repliesCount;
  List<dynamic> replies;
  List<dynamic> likes;
  UserAccount user;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"],
        comment: json["comment"],
        productId: json["product_id"],
        userId: json["user_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        likesCount: json["likes_count"],
        repliesCount: json["replies_count"],
        replies: List<dynamic>.from(json["replies"].map((x) => x)),
        likes: List<dynamic>.from(json["likes"].map((x) => x)),
        user: UserAccount.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "comment": comment,
        "product_id": productId,
        "user_id": userId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "likes_count": likesCount,
        "replies_count": repliesCount,
        "replies": List<dynamic>.from(replies.map((x) => x)),
        "likes": List<dynamic>.from(likes.map((x) => x)),
        "user": user.toJson(),
      };
}
