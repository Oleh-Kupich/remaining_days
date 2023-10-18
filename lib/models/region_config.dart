import 'dart:convert';

import 'package:remaining_days/models/stay_item.dart';

class RegionConfig {
  String name;
  int maxStay;
  int rollingPeriod;
  bool sortAscending;
  bool selected;
  List<StayItem> stays;

  RegionConfig(
      {required this.name,
      required this.maxStay,
      required this.rollingPeriod,
      required this.sortAscending,
      required this.selected,
      required this.stays});

  static RegionConfig defaultConfig() =>
      RegionConfig(name: "Default", maxStay: 90, rollingPeriod: 180, sortAscending: true, selected: true, stays: []);

  factory RegionConfig.fromJson(Map<String, dynamic> jsonData) => RegionConfig(
        name: jsonData['name'],
        maxStay: jsonData['maxStay'],
        rollingPeriod: jsonData['rollingPeriod'],
        sortAscending: jsonData['sortAscending'],
        selected: jsonData['selected'],
        stays: List<StayItem>.from((jsonData['stays'] as List).map((stay) => StayItem.fromJson(stay))),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'maxStay': maxStay,
        'rollingPeriod': rollingPeriod,
        'sortAscending': sortAscending,
        'selected': selected,
        'stays': stays,
      };

  static String serialize(RegionConfig model) => jsonEncode(model.toJson());

  static RegionConfig deserialize(String json) => RegionConfig.fromJson(jsonDecode(json));
}
