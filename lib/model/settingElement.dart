import 'package:flutter/material.dart';

class SettingElement {
}

class SettingItem implements SettingElement {
  String titleKey;
  void Function(BuildContext) action;
  SettingItem({ this.titleKey, this.action });
}

class SettingSeparator implements SettingElement {
  String titleKey;
  SettingSeparator({ this.titleKey });
}