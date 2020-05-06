
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/invitationCodeViewModel.dart';

class InvitationCodeView extends StatefulWidget {

  @override
  _InvitationCodeViewState createState() => _InvitationCodeViewState();
}

class _InvitationCodeViewState extends State<InvitationCodeView> {
  final _generatingInvitationCodeFont = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Color(0x0088000000));
  InvitationCodeViewModel _viewModel;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          L10n.of(context).invitationCode
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
            : QrImage(
              data: invitationCodeJson,
              version: QrVersions.auto,
              size: 200,
            )
        );
      }
    );
  }
}