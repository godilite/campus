import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class UploadService {
  Future saveImage(Asset asset) async {
    var time = DateTime.now().toIso8601String();
    ByteData byteData =
        await asset.getByteData(); // requestOriginal is being deprecated
    List<int> imageData = byteData.buffer.asUint8List();
    StorageReference ref = FirebaseStorage()
        .ref()
        .child("$time"); // To be aligned with the latest firebase API(4.0)
    StorageUploadTask uploadTask = ref.putData(imageData);

    return await (await uploadTask.onComplete).ref.getDownloadURL();
  }
}
