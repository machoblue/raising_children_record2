
import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterViewModel with ViewModelErrorHandler implements ViewModel {

  final GoogleSignIn googleSignIn = GoogleSignIn();

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

  StreamSubscription _onAppearSubscription;

  RegisterViewModel() {
    _onAppearSubscription = _onAppearStream.stream.listen((_) {
      _showIndicatorStreamController.sink.add(true);

      _isSignIn()
        .then((isSignIn) {
          if (isSignIn) {
            _onSignInStreamController.sink.add(null);
          }
          _showIndicatorStreamController.sink.add(false);
        })
        .catchError(_handleError);
    });
  }

  Future<bool> _isSignIn() {
    return googleSignIn.isSignedIn().then((isSignIn) {
      if (!isSignIn) {
        return false;
      }

      return SharedPreferences.getInstance().then((sharedPreferences) {
        final userId = sharedPreferences.getString("userId");
        return userId?.isNotEmpty ?? false;
      });
    });
  }

  void _handleError(Object error) {
    _showIndicatorStreamController.sink.add(false);
    handleError(error);
  }

  @override
  void dispose() {
    super.dispose();

    _onAppearSubscription.cancel();

    _onAppearStream.close();
    _onGoogleButtonTappedStream.close();
    _onAnonymousButtonTappedStream.close();
    _onDialogSignInButtonTappedStream.close();
    _onSignInStreamController.close();
    _alreadyRegisteredStreamController.close();
    _showIndicatorStreamController.close();
  }
}