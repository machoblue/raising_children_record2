
mixin FirebaseStorageErrorHandler {
  void handleError(Object error) {
    // TODO: Crasylytics
    print("### FirebaseStoragetErrorHandler.error: $error");
    throw FileAccessException();
  }
}

class FileAccessException implements Exception {}