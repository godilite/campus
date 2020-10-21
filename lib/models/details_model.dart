import 'package:camp/models/product_model.dart';
import 'comment_model.dart';
import 'product_like.dart';

class Details {
  Details({
    this.comments,
    this.images,
    this.product,
    this.productLikes,
  });

  List<Comment> comments;
  List<dynamic> images;
  Product product;
  List<ProductLike> productLikes;

  factory Details.fromJson(Map<String, dynamic> json) => Details(
        comments: List<Comment>.from(
            json["comments"].map((x) => Comment.fromJson(x))),
        images: List<dynamic>.from(json["images"].map((x) => x)),
        product: Product.fromJson(json["product"]),
        productLikes: List<ProductLike>.from(
            json["product_likes"].map((x) => ProductLike.fromJson(x))),
      );

  // Map<String, dynamic> toJson() => {
  //       "comments": comments.toJson(),
  //       "images": List<dynamic>.from(images.map((x) => x)),
  //       "product": product.toJson(),
  //       "product_likes":
  //           List<dynamic>.from(productLikes.map((x) => x.toJson())),
  //     };
}
