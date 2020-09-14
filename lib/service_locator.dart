import 'package:camp/services/AuthService.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.I;

void setupLocator() {
  locator.registerSingleton(AuthService());
}
