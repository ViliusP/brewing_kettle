import 'package:brew_kettle_dashboard/core/data/models/timeseries/timeseries.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // group('TimeSeries Tests', () {
  //   test('Add single entry', () {
  //     final timeSeries = TimeSeries();
  //     final entry = TimeSeriesEntry(DateTime(2025, 1, 1), 10);
  //     timeSeries.add(entry);

  //     expect(timeSeries.data.length, 1);
  //     expect(timeSeries.data.first, entry);
  //   });

  //   test('Add multiple entries', () {
  //     final timeSeries = TimeSeries();
  //     final entries = [
  //       TimeSeriesEntry(DateTime(2025, 1, 1), 10),
  //       TimeSeriesEntry(DateTime(2025, 1, 2), 20),
  //     ];
  //     timeSeries.addAll(entries);

  //     expect(timeSeries.data.length, 2);
  //     expect(timeSeries.data, entries);
  //   });

  //   test('Aggregate by mean', () {
  //     final timeSeries = TimeSeries.from([
  //       TimeSeriesEntry(DateTime(2025, 1, 1, 0, 0), 10),
  //       TimeSeriesEntry(DateTime(2025, 1, 1, 0, 30), 20),
  //       TimeSeriesEntry(DateTime(2025, 1, 1, 1, 0), 30),
  //     ]);

  //     final result = timeSeries.aggregate(
  //       type: AggregationType.mean,
  //       interval: AggregationInterval.hours(1),
  //     );

  //     expect(result.length, 2);
  //     expect(result[0].value, 15); // Mean of 10 and 20
  //     expect(result[1].value, 30); // Single value remains
  //   });

  //   test('Aggregate by sum', () {
  //     final timeSeries = TimeSeries.from([
  //       TimeSeriesEntry(DateTime(2025, 1, 1, 0, 0), 5),
  //       TimeSeriesEntry(DateTime(2025, 1, 1, 0, 30), 15),
  //     ]);

  //     final result = timeSeries.aggregate(
  //       type: AggregationType.sum,
  //       interval: AggregationInterval.hours(1),
  //     );

  //     expect(result.length, 1);
  //     expect(result.first.value, 20); // Sum of 5 and 15
  //   });

  //   test('Aggregate with missing value handler', () {
  //     final timeSeries = TimeSeries.from([
  //       TimeSeriesEntry(DateTime(2025, 1, 1, 0, 0), 10),
  //     ]);

  //     final result = timeSeries.aggregate(
  //       type: AggregationType.mean,
  //       interval: AggregationInterval.hours(1),
  //       missingValueHandler: ValueFillerHandler(0),
  //     );

  //     expect(result.length, 1);
  //     expect(result.first.value, 10);
  //   });

  //   test('Aggregate by median', () {
  //     final timeSeries = TimeSeries.from([
  //       TimeSeriesEntry(DateTime(2025, 1, 1, 0, 0), 10),
  //       TimeSeriesEntry(DateTime(2025, 1, 1, 0, 30), 20),
  //       TimeSeriesEntry(DateTime(2025, 1, 1, 0, 45), 30),
  //     ]);

  //     final result = timeSeries.aggregate(
  //       type: AggregationType.median,
  //       interval: AggregationInterval.hours(1),
  //     );

  //     expect(result.length, 1);
  //     expect(result.first.value, 20); // Median of 10, 20, 30
  //   });

  //   test('Aggregate by min', () {
  //     final timeSeries = TimeSeries.from([
  //       TimeSeriesEntry(DateTime(2025, 1, 1, 0, 0), 5),
  //       TimeSeriesEntry(DateTime(2025, 1, 1, 0, 30), 15),
  //     ]);

  //     final result = timeSeries.aggregate(
  //       type: AggregationType.min,
  //       interval: AggregationInterval.hours(1),
  //     );

  //     expect(result.length, 1);
  //     expect(result.first.value, 5); // Minimum of 5 and 15
  //   });

  //   test('Aggregate by max', () {
  //     final timeSeries = TimeSeries.from([
  //       TimeSeriesEntry(DateTime(2025, 1, 1, 0, 0), 5),
  //       TimeSeriesEntry(DateTime(2025, 1, 1, 0, 30), 15),
  //     ]);

  //     final result = timeSeries.aggregate(
  //       type: AggregationType.max,
  //       interval: AggregationInterval.hours(1),
  //     );

  //     expect(result.length, 1);
  //     expect(result.first.value, 15); // Maximum of 5 and 15
  //   });

  //   test('Empty aggregation uses ValueFillerHandler', () {
  //     final timeSeries = TimeSeries();

  //     final result = timeSeries.aggregate(
  //       type: AggregationType.mean,
  //       interval: AggregationInterval.hours(1),
  //       missingValueHandler: ValueFillerHandler(0),
  //     );

  //     expect(result.isEmpty, true);
  //   });
  // });
}
