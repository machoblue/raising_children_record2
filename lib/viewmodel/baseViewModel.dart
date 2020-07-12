
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:raisingchildrenrecord2/data/firestoreErrorHandler.dart';
import 'package:raisingchildrenrecord2/storage/firebaseStorageErrorHandler.dart';

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
  final _errorMessageStreamController = StreamController<ErrorMessage>();
  Stream<ErrorMessage> get errorMessage => _errorMessageStreamController.stream;
  StreamSink<ErrorMessage> get errorMessageSink => _errorMessageStreamController.sink;

  void handleError(Object error) {
    print("### ViewModelErrorHandler.error: $error");
    String title = Intl.message('Error', name: 'error');
    String message = Intl.message('Error has occured.', name: 'errorMessage');

    switch (error.runtimeType) {
      case PermissionException:
        message = Intl.message('Cannot access data. This operation is unexpected. Please tell us what did you do.', name: 'permissionError');
        break;
      case DataAccessException:
        message = Intl.message('Error has occured on accessing data. Please retry later.', name: 'dataAccessError');
        break;
      case FileAccessException:
        message = Intl.message('Error has occured on accessing files. Please retry later.', name: 'fileAccessError');
        break;
      default:
        break;
    }

    _errorMessageStreamController.sink.add(ErrorMessage(title, message));
  }

  void dispose() {
    _errorMessageStreamController.close();
  }
}