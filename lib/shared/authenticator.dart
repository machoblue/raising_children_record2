
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:raisingchildrenrecord2/model/authenticatedUser.dart';

class Authenticator {
  Future<AuthenticatedUser> authenticate() {}
}

class AuthenticateCancelledException {}
class AuthenticateFailedException {}

class GoogleAuthenticator implements Authenticator {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<AuthenticatedUser> authenticate() {
    return googleSignIn.signIn().then((GoogleSignInAccount account) {
      if (account == null) {
        throw AuthenticateCancelledException();
      }

      return account.authentication.then((GoogleSignInAuthentication auth) async {
        final AuthCredential credential = GoogleAuthProvider.getCredential(idToken: auth.idToken, accessToken: auth.accessToken);
        return firebaseAuth.signInWithCredential(credential).then((AuthResult result) {
          final FirebaseUser firebaseUser = result.user;
          if (firebaseUser == null) {
            throw AuthenticateFailedException();
          }
          return AuthenticatedUser.fromFirebaseUser(firebaseUser, SignInMethod.google);
        });
      });
    });
  }
}