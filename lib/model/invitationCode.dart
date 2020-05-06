
import 'package:uuid/uuid.dart';

class InvitationCode {
  String code;
  DateTime expirationDate;

  InvitationCode(this.code, this.expirationDate);

  InvitationCode.newInstance(): this(
    Uuid().v1(),
    DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 5),
  );

  Map<String, dynamic> get map {
    return {
      'code': code,
      'expirationDate': expirationDate,
    };
  }
}