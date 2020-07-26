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
  String get mothersMilkLabel => Intl.message('Mothers Milk', name: 'mothersMilkLabel');
  String get vomitLabel => Intl.message('Vomit', name: 'vomitLabel');
  String get coughLabel => Intl.message('Cough', name: 'coughLabel');
  String get rashLabel => Intl.message('Rash', name: 'rashLabel');
  String get medicineLabel => Intl.message('Medicine', name: 'medicineLabel');
  String get peeLabel => Intl.message('Pee', name: 'peeLabel');
  String get etcLabel => Intl.message('etc.', name: 'etcLabel');
  String get sleepLabel => Intl.message('Sleep', name: 'sleepLabel');
  String get awakeLabel => Intl.message('Awake', name: 'awakeLabel');
  String get poopLabel => Intl.message('Poop', name: 'poopLabel');
  String get bodyTemperatureLabel => Intl.message('Body Temperature', name: 'bodyTemperatureLabel');
  String get heightLabel => Intl.message('Height', name: 'heightLabel');
  String get weightLabel => Intl.message('Weight', name: 'weightLabel');

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
  String get danger => Intl.message('*** DANGER ***', name: 'danger');

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
  String get left => Intl.message('Left', name: 'left');
  String get right => Intl.message('Right', name: 'right');

  String get hardnessLabel => Intl.message('Hardness', name: 'hardnessLabel');
  String get amountLabel => Intl.message('Amount', name: 'amountLabel');
  String get hardnessDiarrhea => Intl.message('Diarrhea', name: 'hardnessDiarrhea');
  String get hardnessSoft => Intl.message('Soft', name: 'hardnessSoft');
  String get hardnessNormal => Intl.message('Normal', name: 'hardnessNormal');
  String get hardnessHard => Intl.message('Hard', name: 'hardnessHard');
  String get amountLittle => Intl.message('Little', name: 'amountLittle');
  String get amountNormal => Intl.message('Normal', name: 'amountNormal');
  String get amountMuch => Intl.message('Much', name: 'amountMuch');

  String get degreesCelsius => Intl.message('℃', name: 'degreesCelsius');
  String get cm => Intl.message('cm', name: 'cm');
  String get kg => Intl.message('kg', name: 'kg');

  String get chartTitle => Intl.message('Chart', name: 'chartTitle');
  String get milkTab => Intl.message('Milk', name: 'milkTab');
  String get sleepTab => Intl.message('Sleep', name: 'sleepTab');
  String get excretionTab => Intl.message('Excretion', name: 'excretionTab');
  String get conditionTab => Intl.message('Condition', name: 'conditionTab');
  String get growthTab => Intl.message('Growth', name: 'growthTab');

  String get oneWeek => Intl.message('1 Week', name: 'oneWeek');
  String get threeWeeks => Intl.message('3 Weeks', name: 'threeWeeks');
  String get threeMonths => Intl.message('3 Months', name: 'threeMonths');

  String get ml => Intl.message('ml', name: 'ml');
  String get hours => Intl.message('Hours', name: 'hours');
  String get total => Intl.message('Total', name: 'total');
  String get average => Intl.message('Average', name: 'average');

  String get times => Intl.message('Times', name: 'times');
  String get poopLegend => Intl.message('the number of poops(diarrhea)', name: 'poopLegend');
  String get peeLegend => Intl.message('the number of pee', name: 'peeLegend');

  String get male => Intl.message('Male', name: 'male');
  String get female => Intl.message('Female', name: 'female');
  String get none => Intl.message('None', name: 'none');

  String get growthLabelOneYear => Intl.message('To 1 Year Old', name: 'growthLabelOneYear');
  String get growthLabelThreeYears => Intl.message('To 3 Years Old', name: 'growthLabelThreeYears');
  String get growthLabelSixYears => Intl.message('To 6 Years Old', name: 'growthLabelSixYears');

  String get monthsOld => Intl.message('mos.', name: 'monthsOld');
  String get yearsOld => Intl.message('yrs.', name: 'yearsOld');

  String get requestReviewDialogTitle => Intl.message('Please rate this app.', name: 'requestReviewDialogTitle');
  String get requestReviewDialogContent => Intl.message('Would you rate this app?', name: 'requestReviewDialogContent');
  String get requestReviewDialogNo => Intl.message('No, Thank you.', name: 'requestReviewDialogNo');
  String get requestReviewDialogOK => Intl.message('OK', name: 'requestReviewDialogOK');

  String get signUpTitle => Intl.message('Sign Up', name: 'signUpTitle');
  String get appName => Intl.message('Raising Children Records 2', name: 'appName');
  String get signUpWithGoogle => Intl.message('Sign up with Google', name: 'signUpWithGoogle');
  String get useAsGuest => Intl.message('Use as guest', name: 'useAsGuest');
  String get signInWithExistingAccount => Intl.message('Sign in', name: 'signInWithExistingAccount');
  String get confirm => Intl.message('Confirm', name: 'confirm');
  String get alreadyRegistered => Intl.message('Your account has already exist. Sign in with the account?', name: "alreadyRegistered");
  String get cancel => Intl.message('Cancel', name: 'cancel');
  String get authenticationCanceled => Intl.message('Authentication was canceled.', name: 'authenticationCanceled');
  String get authenticationFailed => Intl.message('Authentication was failed.', name: 'authenticationFailed');

  String get loginError => Intl.message('Login Error', name: 'loginError');
  String get userNotExists => Intl.message('User does not exist', name: 'userNotExists');
}