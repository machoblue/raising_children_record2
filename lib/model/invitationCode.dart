
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

  Map<String, dynamic> get map {
    return {
      'code': code,
      'familyId': familyId,
      'expirationDate': expirationDate,
    };
  }
}