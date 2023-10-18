import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StayItem extends DateTimeRange {
  StayItem({required super.start, required super.end});

  StayItem.ofDateTimeRange(DateTimeRange dateTimeRange) : super(start: dateTimeRange.start, end: dateTimeRange.end);

  String get key => super.toString();

  @override
  String toString() => '${DateFormat('d MMM y').format(start)} - ${DateFormat('d MMM y').format(end)}';

  factory StayItem.fromJson(Map<String, dynamic> jsonData) => StayItem(
    start: DateTime.parse(jsonData['start']),
    end: DateTime.parse(jsonData['end']),
  );

  Map<String, dynamic> toJson() => {
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
  };
}
