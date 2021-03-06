import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/data/babyRepository.dart';
import 'package:raisingchildrenrecord2/data/familyRepository.dart';
import 'package:raisingchildrenrecord2/data/userRepository.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/settingElement.dart';
import 'package:intl/intl.dart';
import 'package:raisingchildrenrecord2/model/user.dart';
import 'package:raisingchildrenrecord2/shared/authenticator.dart';
import 'package:raisingchildrenrecord2/storage/storageUtil.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/loginView.dart';
import 'package:raisingchildrenrecord2/view/registerView.dart';
import 'package:raisingchildrenrecord2/view/setting/babyListView.dart';
import 'package:raisingchildrenrecord2/view/setting/buttonOrderView.dart';
import 'package:raisingchildrenrecord2/view/setting/invitationCodeView.dart';
import 'package:raisingchildrenrecord2/view/setting/settingsViewTutorial.dart';
import 'package:raisingchildrenrecord2/view/setting/userEditView.dart';
import 'package:raisingchildrenrecord2/viewmodel/loginViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/registerViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/babyListViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/buttonOrderViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/invitationCodeViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/userEditViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/settingsViewModel.dart';

class SettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsViewState();
}

class _SettingsViewState extends BaseState<SettingsView, SettingsViewModel> with SettingsViewTutorial {
  final _groupTitleFont = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Color(0x0088000000));

  List<SettingElement> settingElements = [];

  StreamSubscription _logoutSubscription;

  @override
  void initState() {
    super.initState();
    settingElements = createSettingElements();
    _logoutSubscription = viewModel.logoutComplete.listen((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Provider(
            create: (_) => RegisterViewModel(GoogleAuthenticator(), GuestAuthenticator(), FirestoreUserRepository(), FirestoreBabyRepository()),
            child: RegisterView(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[16],
      child: Stack(
        children: <Widget>[
          _buildListView(context),
          _indicator(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _logoutSubscription.cancel();
  }

  Widget _buildListView(BuildContext context) {
    return ListView.builder(
      itemCount: settingElements.length,
      itemBuilder: (context, index) {
        SettingElement element = settingElements[index];
        switch (element.runtimeType) {
          case SettingSeparator: {
            return _buildSeparator(element as SettingSeparator);
          }
          case SettingItem: {
            return _buildItem(element as SettingItem);
          }
          default: {
            throw("This line shouldn't be reached.");
          }
        }
      },
    );
  }

  Widget _buildSeparator(SettingSeparator separator) {
    return Container(
      height: 48,
      alignment: Alignment.bottomLeft,
      padding: EdgeInsets.fromLTRB(16, 0, 0, 4),
      child: separator.titleKey == null
        ? Container()
        : Text(
          Intl.message('${separator.titleKey}', name: '${separator.titleKey}'),
          style: _groupTitleFont,
        ),
    );
  }

  Widget _buildItem(SettingItem item) {
    return GestureDetector(
      onTap: () => item.action(context),
      child: Container(
        key: item.globalKey,
        padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(width: 0.25, color: Color(0x0064000000)),
            bottom: BorderSide(width: 0.25, color: Color(0x0064000000)),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                Intl.message('${item.titleKey}', name: '${item.titleKey}'),
              ),
            ),
            Icon(
              Icons.chevron_right,
            )
          ],
        ),
      ),
    );
  }


  Widget _indicator() {
    return StreamBuilder(
      stream: viewModel.isLoading,
      builder: (context, snapshot) {
        final bool isLoading = snapshot.data ?? false;
        return isLoading
            ? Center(
            child: CircularProgressIndicator()
        )
            : Container();
      }
    );
  }

  List<SettingElement> createSettingElements() =>[
    SettingSeparator(titleKey: 'basicSettings'),
    SettingItem(
      titleKey: 'editRecordButtonsOrder',
      globalKey: editRecordButtonsOrderKey,
      action: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) {
                return Provider<ButtonOrderViewModel>(
                  create: (_) => ButtonOrderViewModel(),
                  child: ButtonOrderView(),
                );
              }
          ),
        );
      },
    ),
    SettingItem(
      titleKey: 'editBabyInfo',
      globalKey: editBabyInfoKey,
      action: (context) {
        Stream<List<Baby>> babiesStream = Provider.of<MainViewModel>(context).babies;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) {
                  return Provider<BabyListViewModel>(
                    create: (_) => BabyListViewModel(babiesStream),
                    child: BabyListView(),
                  );
                }
            )
        );
      },
    ),
    SettingSeparator(titleKey: 'shareData'),
    SettingItem(
      titleKey: 'showInvitationCode',
      action: (context) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) {
                  return Provider<InvitationCodeViewModel>(
                    create: (_) => InvitationCodeViewModel(FirestoreFamilyRepository()),
                    child: InvitationCodeView(),
                  );
                }
            )
        );
      },
    ),
    SettingSeparator(titleKey: 'account'),
    SettingItem(
      titleKey: 'editUserInfo',
      action: (context) {
        Stream<User> userStream = Provider.of<MainViewModel>(context).user;
        StreamSubscription subscription;
        subscription = userStream.listen((user) {
          subscription.cancel(); // listen once
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) {
                    return Provider<UserEditViewModel>(
                      create: (_) => UserEditViewModel(user, FirestoreUserRepository(), FirebaseStorageUtil()),
                      child: UserEditView(user),
                    );
                  }
              )
          );
        });
      },
    ),
    SettingItem(
      titleKey: 'logout',
      action: (context) => Provider.of<SettingsViewModel>(context).onLogoutButtonTapped.add(null),
    ),
    SettingSeparator(titleKey: 'danger'),
    SettingItem(
      titleKey: 'clearAllData',
      action: (context) {
        SettingsViewModel viewModel = Provider.of<SettingsViewModel>(context);
        showDialog(
          context: context,
          builder: (_) {
            L10n l10n = L10n.of(context);
            return AlertDialog(
              title: Text(l10n.clearAllData),
              content: Text(l10n.clearAllDataMessage),
              actions: <Widget>[
                // ボタン領域
                FlatButton(
                  child: Text(l10n.no),
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton(
                    child: Text(l10n.yes),
                    onPressed: () {
                      print("### onYesPressed");
                      viewModel.onClearAllDataItemTapped.add(null);
                      Navigator.pop(context);
                    }
                ),
              ],
            );
          },
        );
      },
    ),
    SettingSeparator(),
  ];
}