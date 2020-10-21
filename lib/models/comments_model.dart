import 'comment_model.dart';

class Comments {
  Comments({
    this.comments,
  });

  List<Comment> comments;

  factory Comments.fromJson(Map<String, dynamic> json) => Comments(
        comments: List<Comment>.from(
            json["comments"].map((x) => Comment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
      };
}
