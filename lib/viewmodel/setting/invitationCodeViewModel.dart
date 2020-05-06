
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raisingchildrenrecord2/model/invitationCode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvitationCodeViewModel {

  final StreamController<void> _onInitStateStreamController = StreamController<void>();
  StreamSink<void> get onInitState => _onInitStateStreamController.sink;

  final StreamController<String> _invitationCodeJSONStreamController = StreamController<String>();
  Stream<String> get invitationCodeJSON => _invitationCodeJSONStreamController.stream;

  InvitationCodeViewModel() {
    _onInitStateStreamController.stream.listen((_) => _generateInvitationCode());
  }

  void _generateInvitationCode() async {
    InvitationCode invitationCode = InvitationCode.newInstance();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String familyId = await sharedPreferences.getString('familyId');

    Firestore.instance
      .collection('families')
      .document(familyId)
      .collection("invitationCodes")
      .document(invitationCode.code)
      .setData(invitationCode.map)
      .then((_) {
        String json = invitationCode.map.toString();
        print("### json: $json");
        _invitationCodeJSONStreamController.sink.add(json);
      });
  }

  void dispose() {
    _onInitStateStreamController.close();
    _invitationCodeJSONStreamController.close();
  }
}