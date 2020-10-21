import 'package:camp/models/user_account.dart';

class ProductLike {
  ProductLike({
    this.id,
    this.userId,
    this.productId,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  int id;
  int userId;
  int productId;
  dynamic createdAt;
  dynamic updatedAt;
  UserAccount user;

  factory ProductLike.fromJson(Map<String, dynamic> json) => ProductLike(
        id: json["id"],
        userId: json["user_id"],
        productId: json["product_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        user: UserAccount.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "product_id": productId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "user": user.toJson(),
      };
}
