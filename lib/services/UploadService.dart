import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:uuid/uuid.dart';

class UploadService {
  var uuid = Uuid();

  var time = DateTime.now().toIso8601String();

  Future saveImage(Asset asset) async {
    var imageId = uuid.v1();
    ByteData byteData =
        await asset.getByteData(); // requestOriginal is being deprecated
    List<int> imageData = byteData.buffer.asUint8List();
    StorageReference ref = FirebaseStorage().ref().child(
        "uploads/$time$imageId"); // To be aligned with the latest firebase API(4.0)
    StorageUploadTask uploadTask = ref.putData(imageData);

    return await (await uploadTask.onComplete).ref.getDownloadURL();
  }

  final picker = ImagePicker();

  Future uplaodImage() async {
    var imageId = uuid.v1();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/$time$imageId');
    StorageUploadTask uploadTask =
        firebaseStorageRef.putFile(File(pickedFile.path));
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    return await taskSnapshot.ref.getDownloadURL();
  }
}
