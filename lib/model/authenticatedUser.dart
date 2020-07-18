
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticatedUser {
  String id;
  String name;
  String photoUrl;
  AuthenticatedUser(this.id, this.name, this.photoUrl);
  AuthenticatedUser.fromFirebaseUser(FirebaseUser firebaseUser): this(firebaseUser.uid, firebaseUser.displayName, firebaseUser.photoUrl);
}