import 'dart:math';

import 'package:flutter/material.dart';
import 'package:remaining_days/models/stay_item.dart';
import 'package:remaining_days/widgets/list_item_widgets/stay_item.dart';
import 'package:remaining_days/widgets/stays_fab_widget.dart';

import '../widgets/bottom_bar_widget/widget.dart';
import '../widgets/date_range_picker_widget.dart';
import '../widgets/list_item_widgets/empty_stay.dart';
import '../widgets/bottom_bar_widget/controller.dart';

List<DateTimeRange> mergeFirst2RangesIfIntersect(List<DateTimeRange> ranges) {
  if (ranges.length < 2) return ranges;

  var range1 = ranges[0];
  var range2 = ranges[1];
  return !range1.end.isBefore(range2.start)
      ? [DateTimeRange(start: range1.start, end: range1.end.isAfter(range2.end) ? range1.end : range2.end)] +
          ranges.sublist(2)
      : ranges;
}

List<DateTimeRange> mergeRangesIfIntersect(List<DateTimeRange> ranges, {bool skipFuture = false}) {
  var sortedRanges = List.of(ranges);
  sortedRanges.sort((range1, range2) => range1.start.compareTo(range2.start));
  if (skipFuture) {
    sortedRanges.removeWhere((range) => range.start.isAfter(DateTime.now()));
    sortedRanges.map((range) => range.end.isAfter(DateTime.now()) ? DateTimeRange(start: range.start, end: DateTime.now()) : range);
  }
  var mergedStays = List<DateTimeRange>.empty(growable: true);
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
  int totalDays = 0;
  if (stays.isEmpty) return (totalDays, null);

  var mergedStays = mergeRangesIfIntersect(stays, skipFuture: skipFutureDates);
  if (mergedStays.isEmpty) return (totalDays, null);

  DateTime back180days =
      DateTime(mergedStays.last.end.year, mergedStays.last.end.month, mergedStays.last.end.day - (rollingRange - 1));
  for (DateTimeRange dateRange in mergedStays) {
    if (dateRange.end.isBefore(back180days)) continue;

    int daysInThisStay =
        dateRange.end.difference(back180days.isAfter(dateRange.start) ? back180days : dateRange.start).inDays + 1;
    totalDays += daysInThisStay;
  }

  return (totalDays, DateTimeRange(start: mergedStays.first.start, end: mergedStays.last.end));
}