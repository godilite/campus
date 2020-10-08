import 'package:camp/models/comment_model.dart';
import 'package:camp/models/user_account.dart';

class CombineStream {
  final CommentModel comment;
  final UserAccount users;

  CombineStream(this.comment, this.users);
}
