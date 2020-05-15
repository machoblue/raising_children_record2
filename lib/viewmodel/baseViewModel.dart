
import 'dart:async';

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
        String title = 'システムエラー';
        String message = 'データにアクセスする権限がありません。想定されていない操作です。どのような操作をしたかを添えてお問い合わせください。';
        errorMessageStreamController.sink.add(ErrorMessage(title, message));
      }
      break;
      case DataAccessException: {
        String title = 'エラー';
        String message = 'データアクセス中にエラーが発生しました。しばらくしてから、もう一度お試しください。';
        errorMessageStreamController.sink.add(ErrorMessage(title, message));
      }
      break;
      default: {
        String title = 'エラー';
        String message = 'エラーが発生しました。';
        errorMessageStreamController.sink.add(ErrorMessage(title, message));
      }
      break;
    }
  }

  void disposeErrorMessageStreamController() {
    errorMessageStreamController.close();
  }
}