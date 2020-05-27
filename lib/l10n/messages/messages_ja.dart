// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ja locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ja';

  static m0(minutes) => "${Intl.plural(minutes, one: '1分', other: '${minutes}分')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "account" : MessageLookupByLibrary.simpleMessage("アカウント"),
    "addBabyTitle" : MessageLookupByLibrary.simpleMessage("赤ちゃん情報 追加"),
    "awakeLabel" : MessageLookupByLibrary.simpleMessage("起きた"),
    "babyButtonTutorial" : MessageLookupByLibrary.simpleMessage("このアイコンをタップすると、赤ちゃんを切り替えることができます。"),
    "babyButtonTutorialDescription" : MessageLookupByLibrary.simpleMessage("※ 赤ちゃんの追加・編集は右下の設定からできます。"),
    "babyFoodLabel" : MessageLookupByLibrary.simpleMessage("離乳食"),
    "babyListTitle" : MessageLookupByLibrary.simpleMessage("赤ちゃん情報 一覧"),
    "basicSettings" : MessageLookupByLibrary.simpleMessage("基本設定"),
    "birthdayLabel" : MessageLookupByLibrary.simpleMessage("生年月日"),
    "cameraAccessDenied" : MessageLookupByLibrary.simpleMessage("This app cannot use camera. Please grant the camera permission from the setting app."),
    "clearAllData" : MessageLookupByLibrary.simpleMessage("退会する（全データ消去）"),
    "clearAllDataMessage" : MessageLookupByLibrary.simpleMessage("退会すると全てのデータが消去されますが、よろしいですか？"),
    "coughLabel" : MessageLookupByLibrary.simpleMessage("せき"),
    "danger" : MessageLookupByLibrary.simpleMessage("※取扱い注意"),
    "dataAccessError" : MessageLookupByLibrary.simpleMessage("データアクセス中にエラーが発生しました。しばらくしてから、もう一度お試しください。"),
    "dataShareComplete" : MessageLookupByLibrary.simpleMessage("データ共有の設定が完了しました。"),
    "editBabyInfo" : MessageLookupByLibrary.simpleMessage("赤ちゃん情報 編集"),
    "editBabyInfoTutorial" : MessageLookupByLibrary.simpleMessage("赤ちゃん情報を追加・編集できます。"),
    "editBabyTitle" : MessageLookupByLibrary.simpleMessage("赤ちゃん情報 編集"),
    "editRecordButtonsOrder" : MessageLookupByLibrary.simpleMessage("記録ボタンの順番を変更する"),
    "editRecordButtonsOrderMessage" : MessageLookupByLibrary.simpleMessage("移動したい項目を長押しした後、移動したい場所にドラッグしてください。"),
    "editRecordButtonsOrderTutorial" : MessageLookupByLibrary.simpleMessage("ホーム画面の記録ボタンの順番を変更できます。"),
    "editUserInfo" : MessageLookupByLibrary.simpleMessage("ユーザー情報 編集"),
    "editUserTitle" : MessageLookupByLibrary.simpleMessage("ユーザー情報 編集"),
    "emptyMessage" : MessageLookupByLibrary.simpleMessage("データがありません。"),
    "error" : MessageLookupByLibrary.simpleMessage("エラー"),
    "errorMessage" : MessageLookupByLibrary.simpleMessage("エラーが発生しました。"),
    "etcLabel" : MessageLookupByLibrary.simpleMessage("その他"),
    "failedToReadInvitationCode" : MessageLookupByLibrary.simpleMessage("Failed to read invitation code."),
    "failedToSignIn" : MessageLookupByLibrary.simpleMessage("ログインに失敗しました。"),
    "fileAccessError" : MessageLookupByLibrary.simpleMessage("ストレージアクセス中にエラーが発生しました。しばらくしてから、もう一度お試しください。"),
    "generatingInvitationCode" : MessageLookupByLibrary.simpleMessage("招待コードを生成中です..."),
    "homeTitle" : MessageLookupByLibrary.simpleMessage("ホーム"),
    "invitationCode" : MessageLookupByLibrary.simpleMessage("招待コード"),
    "invitationCodeExpirationDateFormat" : MessageLookupByLibrary.simpleMessage("有効期限(5分間): %s まで"),
    "invitationCodeInvalid" : MessageLookupByLibrary.simpleMessage("この招待コードは期限が切れているようです。招待コードを発行し直して、再び読み込んでください。"),
    "invitationCodeMessage" : MessageLookupByLibrary.simpleMessage("このQRコードを読み込んだユーザーはあなたとデータを共有できるようになります。"),
    "invitationCodeNote" : MessageLookupByLibrary.simpleMessage("※QRコードを読み込みは、このアプリを初めて起動したときのみ可能です。すでにアプリを利用済みのユーザーと共有する場合、そのユーザーが一度退会してデータを全消去する必要があります。"),
    "left" : MessageLookupByLibrary.simpleMessage("左"),
    "loginButtonLabel" : MessageLookupByLibrary.simpleMessage("Googleでログイン"),
    "loginTitle" : MessageLookupByLibrary.simpleMessage("ログイン"),
    "logout" : MessageLookupByLibrary.simpleMessage("ログアウト"),
    "medicineLabel" : MessageLookupByLibrary.simpleMessage("くすり"),
    "milkLabel" : MessageLookupByLibrary.simpleMessage("ミルク"),
    "minuteUnit" : m0,
    "minutes" : MessageLookupByLibrary.simpleMessage("分"),
    "mothersMilkLabel" : MessageLookupByLibrary.simpleMessage("母乳"),
    "nameLabel" : MessageLookupByLibrary.simpleMessage("名前"),
    "no" : MessageLookupByLibrary.simpleMessage("いいえ、消去しません"),
    "noInvitationCodeButton" : MessageLookupByLibrary.simpleMessage("招待コードを持っていない"),
    "ok" : MessageLookupByLibrary.simpleMessage("OK"),
    "peeLabel" : MessageLookupByLibrary.simpleMessage("おしっこ"),
    "permissionError" : MessageLookupByLibrary.simpleMessage("データにアクセスする権限がありません。想定されていない操作です。どのような操作をしたかを添えてお問い合わせください。"),
    "rashLabel" : MessageLookupByLibrary.simpleMessage("ほっしん"),
    "readInvitationCodeButton" : MessageLookupByLibrary.simpleMessage("招待コードを読み込む"),
    "readingInvitationCodeMessage" : MessageLookupByLibrary.simpleMessage("招待コードを読み込んで、\n他のユーザーとデータを共有しますか？"),
    "readingInvitationCodeTitle" : MessageLookupByLibrary.simpleMessage("招待コードの読み取り"),
    "recordButtonTutorial" : MessageLookupByLibrary.simpleMessage("まずは、記録してみましょう！"),
    "recordButtonTutorialDescription" : MessageLookupByLibrary.simpleMessage("※ これらの記録ボタンの順番は、右下の設定から変更することができます。"),
    "recordDeleteButtonLabel" : MessageLookupByLibrary.simpleMessage("削除"),
    "recordLabelNote" : MessageLookupByLibrary.simpleMessage("メモ"),
    "recordTitleEdit" : MessageLookupByLibrary.simpleMessage("編集"),
    "recordTitleNew" : MessageLookupByLibrary.simpleMessage("新規作成"),
    "right" : MessageLookupByLibrary.simpleMessage("右"),
    "settingsTitle" : MessageLookupByLibrary.simpleMessage("設定"),
    "shareData" : MessageLookupByLibrary.simpleMessage("データ共有"),
    "showInvitationCode" : MessageLookupByLibrary.simpleMessage("招待コードを表示する"),
    "sleepLabel" : MessageLookupByLibrary.simpleMessage("寝た"),
    "snackLabel" : MessageLookupByLibrary.simpleMessage("おやつ"),
    "tutorialSkip" : MessageLookupByLibrary.simpleMessage("スキップ"),
    "vomitLabel" : MessageLookupByLibrary.simpleMessage("おうと"),
    "yes" : MessageLookupByLibrary.simpleMessage("はい、消去します")
  };
}
