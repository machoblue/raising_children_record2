
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/invitationCodeViewModel.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

class InvitationCodeView extends StatefulWidget {

  @override
  _InvitationCodeViewState createState() => _InvitationCodeViewState();
}

class _InvitationCodeViewState extends State<InvitationCodeView> {
  final _generatingInvitationCodeFont = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Color(0x0088000000));
  final _messageFont = TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Color(0x0088000000));
  final _noteFont = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Color(0x0088000000));
  final _expirationDateFont = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0x0088000000));
  final _dateFormat = DateFormat().add_yMd().add_Hms();

  InvitationCodeViewModel _viewModel;
  L10n _l10n;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<InvitationCodeViewModel>(context, listen: false);
    _viewModel.onInitState.add(null);
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _l10n = L10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _l10n.invitationCode
        ),
      ),
      body: _qrCode(),
    );
  }

  Widget _qrCode() {
    return StreamBuilder(
      stream: _viewModel.invitationCodeJSON,
      builder: (context, snapshot) {
        String invitationCodeJson = snapshot.data;
        return Center(
          child: invitationCodeJson == null
            ? Text(
              L10n.of(context).generatingInvitationCode,
              style: _generatingInvitationCodeFont
            )
            : Container(
              padding: EdgeInsets.all(36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _l10n.invitationCodeMessage,
                    style: _messageFont,
                    textAlign: TextAlign.center,
                  ),
                  Container(height: 12),
                  Text(
                    _l10n.invitationCodeNote,
                    style: _noteFont,
                    textAlign: TextAlign.center,
                  ),
                  Container(height: 24),
                  QrImage(
                    data: invitationCodeJson,
                    version: QrVersions.auto,
                    size: 200,
                  ),
                  Container(height: 24),
                  StreamBuilder(
                    stream: _viewModel.expirationDate,
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? Text(
                            sprintf(_l10n.invitationCodeExpirationDateFormat, [_dateFormat.format(snapshot.data)]),
                            style: _expirationDateFont,
                            textAlign: TextAlign.center,
                          )
                          : Container();
                    },
                  ),
                ],
              ),
            ),
        );
      }
    );
  }
}