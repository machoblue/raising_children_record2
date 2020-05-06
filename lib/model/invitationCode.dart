
import 'dart:convert';

import 'package:uuid/uuid.dart';

class InvitationCode {
  String code;
  String familyId;
  DateTime expirationDate;

  InvitationCode(this.code, this.familyId, this.expirationDate);

  InvitationCode.newInstance(String familyId): this(
    Uuid().v1(),
    familyId,
    DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 5),
  );

  InvitationCode.fromJSON(String json) {
    Map map = jsonDecode(json);
    this.code = map['code'] as String;
    this.familyId = map['familyId'] as String;
    this.expirationDate = DateTime.parse(map['expirationDate'] as String);
  }

  Map<String, dynamic> get map {
    return {
      'code': code,
      'familyId': familyId,
      'expirationDate': expirationDate,
    };
  }

  String get json {
    final Map<String, dynamic> map = {
      'code': code,
      'familyId': familyId,
      'expirationDate': expirationDate.toUtc().toIso8601String(),
    };
    return jsonEncode(map);
  }
}