import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:keeo_app/SleepDataPoint.dart';

class SleepMetricsPage extends StatelessWidget {
  final List<charts.Series<SleepDataPoint, DateTime>> dataSeriesList;
  final bool animate;
  SleepMetricsPage(this.dataSeriesList, {required this.animate});

  factory SleepMetricsPage.withSampleData() {
    final data = [
      new SleepDataPoint(new DateTime(2021, 11, 10), 9),
      new SleepDataPoint(new DateTime(2021, 11, 11), 8),
      new SleepDataPoint(new DateTime(2021, 11, 12), 7),
      new SleepDataPoint(new DateTime(2021, 11, 13), 5),
      new SleepDataPoint(new DateTime(2021, 11, 14), 8)
    ];

    return new SleepMetricsPage([new charts.Series<SleepDataPoint, DateTime>(
        id: 'Sleep Data',
        data: data,
        domainFn: (SleepDataPoint sleepData, _) => sleepData.date,
        measureFn: (SleepDataPoint sleepData, _) => sleepData.sleepMetric,
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault)],
        animate: true
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: _sleepDataChart(),
      ),
    );
  }

  Widget _sleepDataChart() {
    return charts.TimeSeriesChart(
      this.dataSeriesList,
      animate: animate,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }
}
