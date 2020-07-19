
import 'package:firebase_auth/firebase_auth.dart';

enum SignInMethod {
  google,
  guest
}

extension SignInMethodExtension on SignInMethod {
  int get rawValue {
    switch (this) {
      case SignInMethod.google:
        return 1;
      case SignInMethod.guest:
        return 2;
      default:
        throw "This line should not be reached.";
    }
  }

  static fromRawValue(int rawValue) {
    switch (rawValue) {
      case 1:
        return SignInMethod.google;
      case 2:
        return SignInMethod.guest;
      default:
        throw "This line should not be reached.";
    }
  }
}

class AuthenticatedUser {
  String id;
  String name;
  String photoUrl;
  SignInMethod signInMethod;
  AuthenticatedUser(this.id, this.name, this.photoUrl, this.signInMethod);
  AuthenticatedUser.fromFirebaseUser(FirebaseUser firebaseUser, SignInMethod signInMethod): this(firebaseUser.uid, firebaseUser.displayName, firebaseUser.photoUrl, signInMethod);
}