
import 'dart:async';

import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';

class RegisterViewModel with ViewModelErrorHandler implements ViewModel {

  // Input
  final _onAppearStream = StreamController<void>();
  StreamSink get onAppear => _onAppearStream.sink;

  final _onGoogleButtonTappedStream = StreamController<void>();
  StreamSink get onGoogleButtonTapped => _onGoogleButtonTappedStream.sink;

  final _onAnonymousButtonTappedStream = StreamController<void>();
  StreamSink get onAnonymousButtonTapped => _onAnonymousButtonTappedStream.sink;

  final _onDialogSignInButtonTappedStream = StreamController<void>();
  StreamSink get onDialogSignInButtonTapped => _onDialogSignInButtonTappedStream.sink;

  // Output
  final _onSignInStreamController = StreamController<void>();
  Stream get onSignIn => _onSignInStreamController.stream;

  final _alreadyRegisteredStreamController = StreamController<void>();
  Stream get alreadyRegistered => _alreadyRegisteredStreamController.stream;

  final _showIndicatorStreamController = BehaviorSubject.seeded(false);
  Stream<bool> get showIndicator => _showIndicatorStreamController.stream;


  RegisterViewModel() {
  }

  @override
  void dispose() {
    super.dispose();

    _onAppearStream.close();
    _onGoogleButtonTappedStream.close();
    _onAnonymousButtonTappedStream.close();
    _onDialogSignInButtonTappedStream.close();
    _onSignInStreamController.close();
    _alreadyRegisteredStreamController.close();
    _showIndicatorStreamController.close();
  }
}