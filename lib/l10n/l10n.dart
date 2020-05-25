import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:raisingchildrenrecord2/l10n/messages/messages_all.dart';

import 'l10n_delegate.dart';

/// アプリでの文言はこれ経由で取得する
class L10n {
  /// 言語リソースを扱う
  ///
  /// localeは端末設定・アプリの指定を踏まえて最適なものが渡ってくる
  static Future<L10n> load(Locale locale) async {
    final name = locale.countryCode == null || locale.countryCode.isEmpty
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);

    // 言語リソース読み込み
    await initializeMessages(localeName);
    // デフォルト言語を設定
    Intl.defaultLocale = localeName;
    // 自身を返す
    return L10n();
  }

  // Widgetツリーから自身を取り出す
  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  static const LocalizationsDelegate<L10n> delegate = L10nDelegate();

  // 以下、Intl.messageを用いて必要な文言を返すgetter・メソッドを定義
  String get loginTitle => Intl.message('Login', name: 'loginTitle');
  String get loginButtonLabel => Intl.message('Sign in with Google', name: 'loginButtonLabel');
  String get failedToSignIn => Intl.message('Failed to sign in.', name: 'failedToSignIn');

  String get homeTitle => Intl.message('Home', name: 'homeTitle');
  String get settingsTitle => Intl.message('Settings', name: 'settingsTitle');

  String get milkLabel => Intl.message('Milk', name: 'milkLabel');
  String get snackLabel => Intl.message('Snack', name: 'snackLabel');
  String get babyFoodLabel => Intl.message('Baby Food', name: 'babyFoodLabel');

  String get recordTitleNew => Intl.message('New', name: 'recordTitleNew');
  String get recordTitleEdit => Intl.message('Edit', name: 'recordTitleEdit');
  String get recordLabelNote => Intl.message('Note', name: 'recordLabelNote');
  String get recordDeleteButtonLabel => Intl.message('Delete', name: 'recordDeleteButtonLabel');

  String get editBabyInfo => Intl.message('Edit baby info', name: 'editBabyInfo');
  String get babyListTitle => Intl.message('Baby List', name: 'babyListTitle');

  String get editBabyTitle => Intl.message('Edit Baby', name: 'editBabyTitle');
  String get addBabyTitle => Intl.message('Add Baby', name: 'addBabyTitle');
  String get nameLabel => Intl.message('Name', name: 'nameLabel');
  String get birthdayLabel => Intl.message('Birthday', name: 'birthdayLabel');

  String get editUserInfo => Intl.message('Edit User Info', name: 'editUserInfo');
  String get editUserTitle => Intl.message('Edit User', name: 'editUserTitle');

  String get shareData => Intl.message('Share Data', name: 'shareData');
  String get showInvitationCode => Intl.message('Show Invitation Code', name: 'showInvitationCode');
  String get invitationCode => Intl.message('Invitation Code', name: 'invitationCode');
  String get generatingInvitationCode => Intl.message('Generating invitation code...', name: 'generatingInvitationCode');
  String get invitationCodeMessage => Intl.message('The user who read this code can share data with you.', name: 'invitationCodeMessage');
  String get invitationCodeNote => Intl.message('NOTE: The user can read this code only when launching this app for the first time. If you wish share data with the existing user, the user need to clear all app data.', name: 'invitationCodeNote');
  String get invitationCodeExpirationDateFormat => Intl.message('Expiration date time(for 5 minutes): \nUntil %s', name: 'invitationCodeExpirationDateFormat');

  String get readingInvitationCodeTitle => Intl.message('Reading Invitation Code', name: 'readingInvitationCodeTitle');
  String get readingInvitationCodeMessage => Intl.message('Do you have an invitation code?', name: 'readingInvitationCodeMessage');
  String get readInvitationCodeButton => Intl.message('Yes, I do.', name: 'readInvitationCodeButton');
  String get noInvitationCodeButton => Intl.message('No, I don\'t.', name: 'noInvitationCodeButton');
  String get dataShareComplete => Intl.message('Finished configuration to share data.', name: 'dataShareComplete');
  String get cameraAccessDenied => Intl.message('This app cannot use camera. Please grant the camera permission from the setting app.', name: 'cameraAccessDenied');
  String get failedToReadInvitationCode => Intl.message('Failed to read invitation code.', name: 'failedToReadInvitationCode');
  String get invitationCodeInvalid => Intl.message('This invitation code isn\'t valid. This may be expired. Please recreate invitation code and read again.', name: 'invitationCodeInvalid');

  String get emptyMessage => Intl.message('No Data', name: 'emptyMessage');

  String get clearAllData => Intl.message('Clear all data', name: 'clearAllData');
  String get clearAllDataMessage => Intl.message('Are you sure clear all data?', name: 'clearAllDataMessage');
  String get yes => Intl.message('Yes.', name: 'yes');
  String get no => Intl.message('No.', name: 'no');

  String get logout => Intl.message('Sign out', name: 'logout');

  String get editRecordButtonsOrder => Intl.message('Edit Record Buttons Order', name: 'editRecordButtonsOrder');
  String get editRecordButtonsOrderMessage => Intl.message('Please keep pressing the item you want to move, and drag it.', name: 'editRecordButtonsOrderMessage');

  String get basicSettings => Intl.message('Basic Settings', name: 'basicSettings');
  String get account => Intl.message('Account', name: 'account');
  String get danger => Intl.message('*** Danger ***', name: 'danger');

  String get ok => Intl.message('OK', name: 'ok');

  String get error => Intl.message('Error', name: 'error');

  String get permissionError => Intl.message('Cannot access data. This operation is unexpected. Please tell us what did you do.', name: 'permissionError');
  String get dataAccessError => Intl.message('Error has occured on accessing data. Please retry later.', name: 'dataAccessError');
  String get errorMessage => Intl.message('Error has occured.', name: 'errorMessage');

  String get fileAccessError => Intl.message('Error has occured on accessing files. Please retry later.', name: 'fileAccessError');

  String get tutorialSkip => Intl.message('Skip', name: 'tutorialSkip');
  String get recordButtonTutorial => Intl.message('First, Let\'s creating a record.', name: 'recordButtonTutorial');
  String get recordButtonTutorialDescription => Intl.message('NOTE: These buttons order can be changed from Settings at the bottom right.', name: 'recordButtonTutorialDescription');
  String get babyButtonTutorial => Intl.message('By this button, you can change baby.', name: 'babyButtonTutorial');
  String get babyButtonTutorialDescription => Intl.message('NOTE: Baby can be added and edited from Settings at the bottom right.', name: 'babyButtonTutorialDescription');
  String get editRecordButtonsOrderTutorial => Intl.message('You can change order of record buttons in home screen.', name: 'editRecordButtonsOrderTutorial');
  String get editBabyInfoTutorial => Intl.message('You can edit and add Baby.', name: 'editBabyInfoTutorial');

  String minuteUnit(int minutes) => Intl.message(
    '${Intl.plural(minutes, one: 'a minute', other: '$minutes minutes')}',
    name: 'minuteUnit',
    args: [minutes],
  );

  String get minutes => Intl.message('minutes', name: 'minutes');
}