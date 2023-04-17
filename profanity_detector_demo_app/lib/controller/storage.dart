import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:get/get.dart';

class Storage extends GetxController {
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  Future<String?> uploadFile(File file) async {
    try {
      // Create a reference to the file to be uploaded
      firebase_storage.Reference ref = _storage.ref('img/${file.path}');

      // Upload the file to firebase
      await ref.putFile(file);

      // Get the download url
      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } on firebase_storage.FirebaseException catch (e) {
      print(e);
      return null;
    }
  }
}
