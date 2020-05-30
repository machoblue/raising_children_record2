
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/view/record/baseRecordView.dart';
import 'package:raisingchildrenrecord2/view/widget/simpleDropdownButton.dart';
import 'package:raisingchildrenrecord2/viewmodel/record/poopMilkRecordViewModel.dart';
import 'package:intl/intl.dart';

class PoopRecordView extends BaseRecordView<PoopRecordViewModel> {
  final _listItemFont = const TextStyle(fontSize: 20.0);
  PoopRecordViewModel viewModel;

  PoopRecordView({ Key key, isNew, onComplete }): super(key: key, isNew: isNew, onComplete: onComplete);

  @override
  Widget buildContent(BuildContext context) {
    viewModel = Provider.of<PoopRecordViewModel>(context);
    return _amountDropDown(context);
  }

  Widget _amountDropDown(BuildContext context) {
    L10n l10n = L10n.of(context);
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
                l10n.hardnessLabel,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )
            ),
            Container(width: 10),
            StreamBuilder(
                stream: viewModel.hardness,
                builder: (context, snapshot) {
                  Hardness hardness = snapshot.data ?? Hardness.normal;
                  return SimpleDropdownButton<Hardness>(
                    value: hardness,
                    items: Hardness.values,
                    itemLabel: (Hardness hardness) => hardness.localizedName,
                    onChanged: (Hardness newValue) => viewModel.onHardnessSelected.add(newValue),
                  );
                }
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
                l10n.amountLabel,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )
            ),
            Container(width: 10),
            StreamBuilder(
                stream: viewModel.amount,
                builder: (context, snapshot) {
                  Amount amount = snapshot.data ?? Amount.normal;
                  return DropdownButton<Amount>(
                    value: amount,
                    items: Amount.values.map((amount) {
                      return DropdownMenuItem<Amount>(
                          value: amount,
                          child: Container(
                              padding: EdgeInsets.fromLTRB(20, 0, 12, 0),
                              child: Text(
                                "${amount.localizedName}",
                                style: _listItemFont,
                              )
                          )
                      );
                    }).toList(),
                    icon: Icon(Icons.expand_more),
                    iconSize: 24,
                    elevation: 16,
                    underline: Container(
                      height: 2,
                      color: Colors.black54,
                    ),
                    onChanged: (Amount newValue) => viewModel.onAmountSelected.add(newValue),
                  );
                }
            ),
          ],
        ),
      ],
    );
  }
}
