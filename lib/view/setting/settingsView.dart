import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/model/baby.dart';
import 'package:raisingchildrenrecord2/model/settingElement.dart';
import 'package:intl/intl.dart';
import 'package:raisingchildrenrecord2/view/setting/babyListView.dart';
import 'package:raisingchildrenrecord2/viewmodel/mainViewModel.dart';
import 'package:raisingchildrenrecord2/viewmodel/setting/babyListViewModel.dart';

class SettingsView extends StatefulWidget {

  List<SettingElement> settingElements = [
    SettingSeparator(),
    SettingItem(
      titleKey: 'editBabyInfo',
      action: (context) {
        Stream<List<Baby>> babiesStream = Provider.of<MainViewModel>(context).babies;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Provider<BabyListViewModel>(
                create: (_) {
                  return BabyListViewModel(babiesStream);
                },
                child: BabyListView(),
              );
            }
          )
        );
      },
    ),
  ];

  @override
  State<StatefulWidget> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    print("### context1: ${context}");
    print("#### settingsView.build");
    Stream<List<Baby>> babiesStream = Provider.of<MainViewModel>(context).babies;
    print("#### settingsView.build2 ${babiesStream}");
    return Container(
      color: Colors.grey[16],
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
    return Container(height: 24);
  }

  Widget _buildItem(SettingItem item) {
    return GestureDetector(
      onTap: () => item.action(context),
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Text(
          Intl.message('${item.titleKey}', name: '${item.titleKey}'),
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(width: 0.25, color: Color(0x0064000000)),
            bottom: BorderSide(width: 0.25, color: Color(0x0064000000)),
          ),
        ),
      ),
    );
  }

}