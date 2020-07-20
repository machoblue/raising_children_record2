
import 'dart:async';

import 'package:raisingchildrenrecord2/data/familyRepository.dart';
import 'package:raisingchildrenrecord2/model/invitationCode.dart';
import 'package:raisingchildrenrecord2/viewmodel/baseViewModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvitationCodeViewModel with ViewModelErrorHandler, ViewModelInfoMessageHandler implements ViewModel {

  final FamilyRepository familyRepository;

  final StreamController<void> _onInitStateStreamController = StreamController<void>();
  StreamSink<void> get onInitState => _onInitStateStreamController.sink;

  final StreamController<String> _invitationCodeJSONStreamController = StreamController<String>();
  Stream<String> get invitationCodeJSON => _invitationCodeJSONStreamController.stream;

  final StreamController<DateTime> _expirationDateStreamController = StreamController<DateTime>();
  Stream<DateTime> get expirationDate => _expirationDateStreamController.stream;

  InvitationCodeViewModel(this.familyRepository) {
    _onInitStateStreamController.stream.listen((_) {
      _generateInvitationCode().then((invitationCode) {
        _invitationCodeJSONStreamController.sink.add(invitationCode.json);
        _expirationDateStreamController.sink.add(invitationCode.expirationDate);
      })
      .catchError(handleError);
    });
  }

  Future<InvitationCode> _generateInvitationCode() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String familyId = sharedPreferences.getString('familyId');

    InvitationCode invitationCode = InvitationCode.newInstance(familyId);

    return familyRepository
      .createInvitationCode(invitationCode, familyId)
      .then((_) => invitationCode);
  }

  void dispose() {
    super.dispose();
    _onInitStateStreamController.close();
    _invitationCodeJSONStreamController.close();
    _expirationDateStreamController.close();
  }
}