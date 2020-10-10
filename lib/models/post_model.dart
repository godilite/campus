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
  final int commentCount;
  final List likes;
  final bool forSale;
  final double amount;
  final String location;
  final double long;
  final double lat;
  final List keywords;
  PostModel(
      {this.id,
      this.title,
      this.author,
      this.userId,
      this.files,
      this.hashtags,
      this.commentId,
      this.content,
      this.likesCount,
      this.commentCount,
      this.likes,
      this.forSale,
      this.amount,
      this.location,
      this.long,
      this.lat,
      this.keywords});

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
      commentCount: data.get('commentCount'),
      amount: data.get('amount'),
      forSale: data.get('forSale'),
      location: data.get('location'),
      lat: data.get('lat'),
      long: data.get('long'),
      keywords: data.get('keywords'),
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
