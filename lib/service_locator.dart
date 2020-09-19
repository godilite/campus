import 'package:camp/services/AuthService.dart';
import 'package:camp/services/PostService.dart';
import 'package:camp/services/UploadService.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.I;

void setupLocator() {
  locator.registerSingleton(AuthService());
  locator.registerSingleton(PostService());
  locator.registerSingleton(UploadService());
}
