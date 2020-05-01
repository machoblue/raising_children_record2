import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/model/settingElement.dart';


class SettingsView extends StatefulWidget {

  List<SettingElement> settingElements = [
    SettingSeparator(),
    SettingItem(
      'editBabyInfo',
      () => print("###"),
    ),
  ];

  @override
  State<StatefulWidget> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: ListView.builder(
        itemCount: widget.settingElements.length,
        itemBuilder: (context, index) {
          SettingElement element = widget.settingElements[index];
          switch (element.runtimeType) {
            case SettingSeparator: {
              return _buildSeparator();
            }
            case SettingItem: {
              return _buildItem(element as SettingItem);
            }
            default: {
              throw("This line shouldn't be reached.");
            }
          }
        },
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(height: 32);
  }

  Widget _buildItem(SettingItem item) {
    return Container(
      color: Colors.white,
      child: Text(
        item.titleKey
      ),
    );
  }

}