import 'package:camp/models/reply_model.dart';
import 'package:camp/models/user_account.dart';

///A combined stream of replies and users
class ReplyStream {
  final ReplyModel reply;
  final UserAccount users;

  ReplyStream(this.reply, this.users);
}
