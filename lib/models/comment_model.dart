class CommentModel {
  final String id;
  final int likesCount;
  final List likes;
  final String content;
  final String uid;
  final String postId;
  final bool hasReply;
  final List replies;
  final timestamp;
  CommentModel(this.content, this.id, this.likes, this.likesCount, this.uid,
      this.hasReply, this.replies, this.postId, this.timestamp);
}
