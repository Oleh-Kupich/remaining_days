import 'dart:convert';

import 'package:remaining_days/models/stay_item.dart';

class RegionConfig {

  RegionConfig(
      {required this.name,
      required this.maxStay,
      required this.rollingPeriod,
      required this.sortAscending,
      required this.selected,
      required this.stays,});

  RegionConfig.defaultConfig() : name = 'Default', maxStay = 90, rollingPeriod = 180, sortAscending = true, selected = true, stays = [];

  String name;
  int maxStay;
  int rollingPeriod;
  bool sortAscending;
  bool selected;
  List<StayItem> stays;

  factory RegionConfig.fromJson(Map<String, dynamic> jsonData) => RegionConfig(
    name: jsonData['name'] as String,
    maxStay: jsonData['maxStay'] as int,
    rollingPeriod: jsonData['rollingPeriod'] as int,
    sortAscending: jsonData['sortAscending'] as bool,
    selected: jsonData['selected'] as bool,
    stays: List<StayItem>.from((jsonData['stays'] as List).map((stay) => StayItem.fromJson(stay as Map<String, dynamic>))),
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

  static RegionConfig deserialize(String json) => RegionConfig.fromJson(jsonDecode(json) as Map<String, dynamic>);
}
