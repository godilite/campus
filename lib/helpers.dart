import 'package:camp/service_locator.dart';
import 'package:camp/services/AuthService.dart';
import 'package:camp/services/UploadService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

var _tapPosition;
UploadService _uploadService = locator<UploadService>();
AuthService _authService = locator<AuthService>();
Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

String truncate(int cutoff, String myString) {
  return (myString.length <= cutoff)
      ? myString
      : '${myString.substring(0, cutoff)}...';
}

List searchKeyword(name) {
  var list = [];
  for (var i = 4; i < name.length + 1; i++) {
    String keyWords = name.substring(0, i);

    list.add(keyWords);
  }
  return list;
}

void storePosition(TapDownDetails details) {
  _tapPosition = details.globalPosition;
}

Future pictureMenu(BuildContext context) async {
  final RenderBox overlay = Overlay.of(context).context.findRenderObject();
  await showMenu(
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    position: RelativeRect.fromRect(
        _tapPosition & Size(140, 0), Offset.zero & overlay.size),
    items: [
      PopupMenuItem(
        child: InkWell(
          onTap: () =>
              _uploadCoverImage().then((value) => Navigator.pop(context)),
          child: Row(
            children: [
              Icon(CupertinoIcons.photo_camera),
              SizedBox(
                width: 20,
              ),
              Text("Change Cover Photo")
            ],
          ),
        ),
      ),
      PopupMenuItem(
        child: InkWell(
          onTap: () =>
              _uploadProfileImage().then((value) => Navigator.pop(context)),
          child: Row(
            children: [
              Icon(CupertinoIcons.profile_circled),
              SizedBox(
                width: 20,
              ),
              Text("Change Profile Picture")
            ],
          ),
        ),
      ),
    ],
    elevation: 2.0,
  );
  return true;
}

Future _uploadCoverImage() async {
  var url = await _uploadService.uplaodImage();
  _authService.updateUserCover(url);
  final SharedPreferences prefs = await _prefs;
  prefs.setString('coverPhoto', url);
}

Future _uploadProfileImage() async {
  var url = await _uploadService.uplaodImage();
  _authService.updateUserPix(url);
  final SharedPreferences prefs = await _prefs;
  prefs.setString('profileUrl', url);
}
