import 'package:camp/models/push_notification.dart';
import 'package:camp/services/AuthService.dart';
import 'package:camp/services/CommentService.dart';
import 'package:camp/services/PostService.dart';
import 'package:camp/services/SearchService.dart';
import 'package:camp/services/UploadService.dart';
import 'package:camp/services/UserService.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.I;

void setupLocator() {
  locator.registerSingleton(PushNotificationService());
  locator.registerSingleton(PostService());
  locator.registerSingleton(AuthService());

  locator.registerSingleton(UploadService());
  locator.registerSingleton(CommentService());
  locator.registerSingleton(UserService());
  locator.registerSingleton(SearchService());
}
