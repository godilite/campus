class ReplyModel {
  final String id;
  final String likesCount;
  final List likes;
  final String content;
  final String uid;
  final String commentId;

  final bool hasReply;
  final List replies;
  final timestamp;
  ReplyModel(this.content, this.id, this.likes, this.likesCount, this.uid,
      this.hasReply, this.replies, this.commentId, this.timestamp);
}
