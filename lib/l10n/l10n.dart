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

  String get readingInvitationCodeTitle => Intl.message('Reading Invitation Code', name: 'readingInvitationCodeTitle');
  String get readingInvitationCodeMessage => Intl.message('Do you have an invitation code?', name: 'readingInvitationCodeMessage');
  String get readInvitationCodeButton => Intl.message('Yes, I do.', name: 'readInvitationCodeButton');
  String get noInvitationCodeButton => Intl.message('No, I don\'t.', name: 'noInvitationCodeButton');
  String get dataShareComplete => Intl.message('Finished configuration to share data.', name: 'dataShareComplete');
}