
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:raisingchildrenrecord2/storage/firebaseStorageErrorHandler.dart';

class StorageUtil {
  Future<dynamic> uploadFile(File file, String fileId) {}
  Future<void> deleteFile(String fileId) {}
}

class FirebaseStorageUtil with FirebaseStorageErrorHandler implements StorageUtil {
  Future<dynamic> uploadFile(File file, String fileId) {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(fileId);
    StorageUploadTask uploadTask = storageReference.putFile(file);
    return uploadTask.onComplete
      .then((storageTaskSnapshot) {
        if (storageTaskSnapshot.error != null) {
          handleError(storageTaskSnapshot.error);
          return null;
        }
        return storageTaskSnapshot.ref.getDownloadURL();
      })
      .catchError(handleError);
  }

  Future<void> deleteFile(String fileId) {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(fileId);
    return storageReference
      .delete()
      .catchError(handleError);
  }
}