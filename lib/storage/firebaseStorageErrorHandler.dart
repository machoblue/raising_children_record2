
mixin FirebaseStorageErrorHandler {
  void handleError(Object error) {
    // TODO: Crasylytics
    throw FileAccessException();
  }
}

class FileAccessException implements Exception {}