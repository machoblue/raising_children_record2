
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

mixin FirestoreUtil {
  static final String environments = 'environments';
  static final String production = 'production';
  static final String develop = 'develop';

  DocumentReference get rootRef {
    return Firestore.instance
      .collection(environments)
      .document(_environmentId);
  }

  String get _environmentId => kReleaseMode ? production : develop;
}