import 'package:flutter/material.dart';

List<DateTimeRange> mergeFirst2RangesIfIntersect(List<DateTimeRange> ranges) {
  if (ranges.length < 2) return ranges;

  final range1 = ranges[0];
  final range2 = ranges[1];
  return !range1.end.isBefore(range2.start)
      ? [DateTimeRange(start: range1.start, end: range1.end.isAfter(range2.end) ? range1.end : range2.end)] +
          ranges.sublist(2)
      : ranges;
}

List<DateTimeRange> mergeRangesIfIntersect(List<DateTimeRange> ranges, {bool skipFuture = false}) {
  var sortedRanges = List.of(ranges)
    ..sort((range1, range2) => range1.start.compareTo(range2.start));
  if (skipFuture) {
    sortedRanges
      ..removeWhere((range) => range.start.isAfter(DateTime.now()))
      ..map((range) => range.end.isAfter(DateTime.now()) ? DateTimeRange(start: range.start, end: DateTime.now()) : range);
  }
  final mergedStays = List<DateTimeRange>.empty(growable: true);
  while (sortedRanges.isNotEmpty) {
    var initialSize = sortedRanges.length;
    while ((sortedRanges = mergeFirst2RangesIfIntersect(sortedRanges)).length < initialSize) {
      initialSize = sortedRanges.length;
    }
    mergedStays.add(sortedRanges.first);
    sortedRanges.removeAt(0);
  }
  return mergedStays;
}

(int, DateTimeRange?) daysStayIn(List<DateTimeRange> stays, {required int rollingRange, required bool skipFutureDates}) {
  var totalDays = 0;
  if (stays.isEmpty) return (totalDays, null);

  final mergedStays = mergeRangesIfIntersect(stays, skipFuture: skipFutureDates);
  if (mergedStays.isEmpty) return (totalDays, null);

  final back180days =
      DateTime(mergedStays.last.end.year, mergedStays.last.end.month, mergedStays.last.end.day - (rollingRange - 1));
  for (final dateRange in mergedStays) {
    if (dateRange.end.isBefore(back180days)) continue;

    final daysInThisStay =
        dateRange.end.difference(back180days.isAfter(dateRange.start) ? back180days : dateRange.start).inDays + 1;
    totalDays += daysInThisStay;
  }

  return (totalDays, DateTimeRange(start: mergedStays.first.start, end: mergedStays.last.end));
}
