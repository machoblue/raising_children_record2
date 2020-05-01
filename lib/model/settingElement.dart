class SettingElement {
}

class SettingItem implements SettingElement {
  String titleKey;
  Function action;

  SettingItem(this.titleKey, this.action);
}

class SettingSeparator implements SettingElement {
}