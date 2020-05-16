
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:raisingchildrenrecord2/data/firestoreErrorHandler.dart';

class ViewModel {
  Stream<ErrorMessage> get errorMessage {}
  dispose() {}
}

class ErrorMessage {
  String title;
  String message;
  ErrorMessage(this.title, this.message);
}

mixin ViewModelErrorHandler {
  final errorMessageStreamController = StreamController<ErrorMessage>();
  Stream<ErrorMessage> get errorMessage => errorMessageStreamController.stream;

  void handleError(Object error) {
    switch (error.runtimeType) {
      case PermissionException: {
        String title = Intl.message('Error', name: 'error');
        String message = Intl.message('Cannot access data. This operation is unexpected. Please tell us what did you do.', name: 'permissionError');
        errorMessageStreamController.sink.add(ErrorMessage(title, message));
      }
      break;
      case DataAccessException: {
        String title = Intl.message('Error', name: 'error');
        String message = Intl.message('Error has occured on accessing data. Please retry later.', name: 'dataAccessError');
        errorMessageStreamController.sink.add(ErrorMessage(title, message));
      }
      break;
      default: {
        String title = Intl.message('Error', name: 'error');
        String message = Intl.message('Error has occured.', name: 'errorMessage');
        errorMessageStreamController.sink.add(ErrorMessage(title, message));
      }
      break;
    }
  }

  void dispose() {
    print("### ViewModelErrorHandler.dispose()");
    errorMessageStreamController.close();
  }
}