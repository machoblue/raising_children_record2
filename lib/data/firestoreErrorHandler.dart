
import 'package:flutter/services.dart';

mixin FirestoreErrorHandler {
  static const String missingOrInsufficientPermissions = 'Error 7';
  void handleError(Object error) {
    switch (error.runtimeType) {
      case PlatformException: {
        final String code = (error as PlatformException).code;
        switch (code) {
          case missingOrInsufficientPermissions: {
            throw PermissionException();
          }

          default: {
            break;
          }
        }
      }
      break;

      default: {
        break;
      }
    }

    throw DataAccessException();
  }
}

class PermissionException implements Exception {}
class DataAccessException implements Exception {}