import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String author;
  final String userId;
  final String title;
  final List files;
  final String content;
  final List hashtags;
  final List commentId;
  final int likesCount;
  final List likes;

  PostModel({
    this.id,
    this.title,
    this.author,
    this.userId,
    this.files,
    this.hashtags,
    this.commentId,
    this.content,
    this.likesCount,
    this.likes,
  });

  factory PostModel.fromData(DocumentSnapshot data) {
    return PostModel(
      id: data.id,
      title: data.get('title'),
      author: data.get('author'),
      files: data.get('files'),
      userId: data.get('userId'),
      hashtags: data.get('hashtags'),
      content: data.get('content'),
      likesCount: data.get('likesCount'),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      id: id,
      title: title,
      content: content,
    }..removeWhere((key, value) => key == null || value == null);
  }
}
