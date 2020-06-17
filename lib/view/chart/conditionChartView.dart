
import 'package:flutter/material.dart';
import 'package:raisingchildrenrecord2/l10n/l10n.dart';
import 'package:raisingchildrenrecord2/model/record.dart';
import 'package:raisingchildrenrecord2/view/baseState.dart';
import 'package:raisingchildrenrecord2/view/widget/calendarLayout.dart';
import 'package:raisingchildrenrecord2/viewmodel/chart/conditionChartViewModel.dart';

class ConditionChartView extends StatefulWidget {
  @override
  _ConditionChartViewState createState() => _ConditionChartViewState();
}

class _ConditionChartViewState extends BaseState<ConditionChartView, ConditionChartViewModel> {
  final TextStyle _baseStyle = TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.normal);
  final TextStyle _bodyTemperatureStyle = TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold);
  final TextStyle _vomitStyle = TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.normal);
  final TextStyle _coughStyle = TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.normal);
  final TextStyle _rashStyle = TextStyle(fontSize: 12, color: Colors.pink, fontWeight: FontWeight.normal);
  final TextStyle _diarrheaStyle = TextStyle(fontSize: 12, color: Colors.brown, fontWeight: FontWeight.normal);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        children: <Widget>[
          StreamBuilder(
            stream: viewModel.data,
            builder: (context, snapshot) {
              if (snapshot.data == null) {
                return Container();
              }
              final ConditionChartData data = snapshot.data;
              final Map<DateTime, ConditionDailyData> dailyDataMap = data.dailyDataMap;
              return Expanded(
                child: CalendarLayout(
                  data.month,
                  onPrevPressed: () => viewModel.monthDecrement.add(null),
                  onNextPressed: () => viewModel.monthIncrement.add(null),
                  dateCellBuilder: (dateTime) {
                    final ConditionDailyData dailyData = dailyDataMap[dateTime];
                    return _buildDateCell(dailyData);
                  },
                ),
              );
            },
          ),
          Container(height: 8),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildDateCell(ConditionDailyData dailyData) {
    if (dailyData == null) {
      return Container();
    }

    L10n l10n = L10n.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        dailyData.bodyTemperature == 0.0
            ? Container()
            : Text(
          '${dailyData.bodyTemperature}${l10n.degreesCelsius}',
          style: dailyData.bodyTemperature >= 37.5 ? _bodyTemperatureStyle : _baseStyle,
        ),
        dailyData.vomitCount == 0
            ? Container()
            : RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: '●', style: _vomitStyle),
              TextSpan(text: '${dailyData.vomitCount}', style: _baseStyle),
            ],
          ),
        ),
        dailyData.coughCount == 0
            ? Container()
            : RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: '●', style: _coughStyle),
              TextSpan(text: '${dailyData.coughCount}', style: _baseStyle),
            ],
          ),
        ),
        dailyData.rashCount == 0
            ? Container()
            : RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: '●', style: _rashStyle),
              TextSpan(text: '${dailyData.rashCount}', style: _baseStyle),
            ],
          ),
        ),
        dailyData.diarrheaCount == 0
            ? Container()
            : RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: '●', style: _diarrheaStyle),
              TextSpan(text: '${dailyData.diarrheaCount}', style: _baseStyle),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    L10n l10n = L10n.of(context);
    return RichText(
      text: TextSpan(
        style: _baseStyle,
        children: <TextSpan>[
          TextSpan(text: '${l10n.degreesCelsius}:${RecordType.bodyTemperature.localizedName}'),
          TextSpan(text: ' ●', style: _vomitStyle),
          TextSpan(text: ':${RecordType.vomit.localizedName}'),
          TextSpan(text: ' ●', style: _coughStyle),
          TextSpan(text: ':${RecordType.cough.localizedName}'),
          TextSpan(text: ' ●', style: _rashStyle),
          TextSpan(text: ':${RecordType.rash.localizedName}'),
          TextSpan(text: ' ●', style: _diarrheaStyle),
          TextSpan(text: ':${Hardness.diarrhea.localizedName}'),
        ],
      ),
    );
  }
}