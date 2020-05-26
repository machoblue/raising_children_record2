// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages locale. All the
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
  String get localeName => 'messages';

  static m0(minutes) => "${Intl.plural(minutes, one: 'a minute', other: '${minutes} minutes')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "account" : MessageLookupByLibrary.simpleMessage("Account"),
    "addBabyTitle" : MessageLookupByLibrary.simpleMessage("Add Baby"),
    "babyButtonTutorial" : MessageLookupByLibrary.simpleMessage("By this button, you can change baby."),
    "babyButtonTutorialDescription" : MessageLookupByLibrary.simpleMessage("NOTE: Baby can be added and edited from Settings at the bottom right."),
    "babyFoodLabel" : MessageLookupByLibrary.simpleMessage("Baby Food"),
    "babyListTitle" : MessageLookupByLibrary.simpleMessage("Baby List"),
    "basicSettings" : MessageLookupByLibrary.simpleMessage("Basic Settings"),
    "birthdayLabel" : MessageLookupByLibrary.simpleMessage("Birthday"),
    "cameraAccessDenied" : MessageLookupByLibrary.simpleMessage("This app cannot use camera. Please grant the camera permission from the setting app."),
    "clearAllData" : MessageLookupByLibrary.simpleMessage("Clear all data"),
    "clearAllDataMessage" : MessageLookupByLibrary.simpleMessage("Are you sure clear all data?"),
    "coughLabel" : MessageLookupByLibrary.simpleMessage("Cough"),
    "danger" : MessageLookupByLibrary.simpleMessage("*** DANGER ***"),
    "dataAccessError" : MessageLookupByLibrary.simpleMessage("Error has occured on accessing data. Please retry later."),
    "dataShareComplete" : MessageLookupByLibrary.simpleMessage("Finished configuration to share data."),
    "editBabyInfo" : MessageLookupByLibrary.simpleMessage("Edit baby info"),
    "editBabyInfoTutorial" : MessageLookupByLibrary.simpleMessage("You can edit and add Baby."),
    "editBabyTitle" : MessageLookupByLibrary.simpleMessage("Edit Baby"),
    "editRecordButtonsOrder" : MessageLookupByLibrary.simpleMessage("Edit Record Buttons Order"),
    "editRecordButtonsOrderMessage" : MessageLookupByLibrary.simpleMessage("Please keep pressing the item you want to move, and drag it."),
    "editRecordButtonsOrderTutorial" : MessageLookupByLibrary.simpleMessage("You can change order of record buttons in home screen."),
    "editUserInfo" : MessageLookupByLibrary.simpleMessage("Edit User Info"),
    "editUserTitle" : MessageLookupByLibrary.simpleMessage("Edit User"),
    "emptyMessage" : MessageLookupByLibrary.simpleMessage("No Data"),
    "error" : MessageLookupByLibrary.simpleMessage("Error"),
    "errorMessage" : MessageLookupByLibrary.simpleMessage("Error has occured."),
    "etcLabel" : MessageLookupByLibrary.simpleMessage("etc."),
    "failedToReadInvitationCode" : MessageLookupByLibrary.simpleMessage("Failed to read invitation code."),
    "failedToSignIn" : MessageLookupByLibrary.simpleMessage("Failed to sign in."),
    "fileAccessError" : MessageLookupByLibrary.simpleMessage("Error has occured on accessing files. Please retry later."),
    "generatingInvitationCode" : MessageLookupByLibrary.simpleMessage("Generating invitation code..."),
    "homeTitle" : MessageLookupByLibrary.simpleMessage("Home"),
    "invitationCode" : MessageLookupByLibrary.simpleMessage("Invitation Code"),
    "invitationCodeExpirationDateFormat" : MessageLookupByLibrary.simpleMessage("Expiration date time(for 5 minutes): \nUntil %s"),
    "invitationCodeInvalid" : MessageLookupByLibrary.simpleMessage("This invitation code isn\'t valid. This may be expired. Please recreate invitation code and read again."),
    "invitationCodeMessage" : MessageLookupByLibrary.simpleMessage("The user who read this code can share data with you."),
    "invitationCodeNote" : MessageLookupByLibrary.simpleMessage("NOTE: The user can read this code only when launching this app for the first time. If you wish share data with the existing user, the user need to clear all app data."),
    "left" : MessageLookupByLibrary.simpleMessage("Left"),
    "loginButtonLabel" : MessageLookupByLibrary.simpleMessage("Sign in with Google"),
    "loginTitle" : MessageLookupByLibrary.simpleMessage("Login"),
    "logout" : MessageLookupByLibrary.simpleMessage("Sign out"),
    "medicineLabel" : MessageLookupByLibrary.simpleMessage("Medicine"),
    "milkLabel" : MessageLookupByLibrary.simpleMessage("Milk"),
    "minuteUnit" : m0,
    "minutes" : MessageLookupByLibrary.simpleMessage("minutes"),
    "mothersMilkLabel" : MessageLookupByLibrary.simpleMessage("Mothers Milk"),
    "nameLabel" : MessageLookupByLibrary.simpleMessage("Name"),
    "no" : MessageLookupByLibrary.simpleMessage("No."),
    "noInvitationCodeButton" : MessageLookupByLibrary.simpleMessage("No, I don\'t."),
    "ok" : MessageLookupByLibrary.simpleMessage("OK"),
    "peeLabel" : MessageLookupByLibrary.simpleMessage("Pee"),
    "permissionError" : MessageLookupByLibrary.simpleMessage("Cannot access data. This operation is unexpected. Please tell us what did you do."),
    "rashLabel" : MessageLookupByLibrary.simpleMessage("Rash"),
    "readInvitationCodeButton" : MessageLookupByLibrary.simpleMessage("Yes, I do."),
    "readingInvitationCodeMessage" : MessageLookupByLibrary.simpleMessage("Do you have an invitation code?"),
    "readingInvitationCodeTitle" : MessageLookupByLibrary.simpleMessage("Reading Invitation Code"),
    "recordButtonTutorial" : MessageLookupByLibrary.simpleMessage("First, Let\'s creating a record."),
    "recordButtonTutorialDescription" : MessageLookupByLibrary.simpleMessage("NOTE: These buttons order can be changed from Settings at the bottom right."),
    "recordDeleteButtonLabel" : MessageLookupByLibrary.simpleMessage("Delete"),
    "recordLabelNote" : MessageLookupByLibrary.simpleMessage("Note"),
    "recordTitleEdit" : MessageLookupByLibrary.simpleMessage("Edit"),
    "recordTitleNew" : MessageLookupByLibrary.simpleMessage("New"),
    "right" : MessageLookupByLibrary.simpleMessage("Right"),
    "settingsTitle" : MessageLookupByLibrary.simpleMessage("Settings"),
    "shareData" : MessageLookupByLibrary.simpleMessage("Share Data"),
    "showInvitationCode" : MessageLookupByLibrary.simpleMessage("Show Invitation Code"),
    "snackLabel" : MessageLookupByLibrary.simpleMessage("Snack"),
    "tutorialSkip" : MessageLookupByLibrary.simpleMessage("Skip"),
    "vomitLabel" : MessageLookupByLibrary.simpleMessage("Vomit"),
    "yes" : MessageLookupByLibrary.simpleMessage("Yes.")
  };
}
