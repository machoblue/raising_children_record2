
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/model/invitationCode.dart';
import 'package:raisingchildrenrecord2/viewmodel/invitationCodeReadViewModel.dart';

class InvitationCodeReadView extends StatefulWidget {
  void Function(InvitationCode) onInvitationCodeRead;

  InvitationCodeReadView({Key key, this.onInvitationCodeRead });

  @override
  _InvitationCodeReadViewState createState() => _InvitationCodeReadViewState();
}

class _InvitationCodeReadViewState extends State<InvitationCodeReadView> {

  InvitationCodeReadViewModel _viewModel;

  String invitationCodeJSON = 'aaa';

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<InvitationCodeReadViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('招待コードの読み取り'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              '招待コードを使って、他のユーザーとデータを共有しますか？'
            ),
            RaisedButton(
              onPressed: _onUseInvitationCodeButtonTapped,
              child: Text(
                '招待コードを使う',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            Text(
              invitationCodeJSON,
            ),
          ],
        ),
      ),
    );
  }

  void _onUseInvitationCodeButtonTapped() async {
    final ScanResult result = await BarcodeScanner.scan();
    final json = result.rawContent.toString();
    print("#### read: $json");
    final InvitationCode invitationCode = InvitationCode.fromJSON(result.toString());
    widget.onInvitationCodeRead(invitationCode);
  }
}