import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:remaining_days/math/remaining_days.dart';
import 'package:remaining_days/models/region_config.dart';
import 'package:remaining_days/models/stay_item.dart';
import 'package:remaining_days/storage/user_preferences.dart';
import 'package:remaining_days/widgets/bottom_bar_widget/controller.dart';
import 'package:remaining_days/widgets/bottom_bar_widget/widget.dart';
import 'package:remaining_days/widgets/date_range_picker_dialog.dart';
import 'package:remaining_days/widgets/list_item_widgets/empty_stay.dart';
import 'package:remaining_days/widgets/list_item_widgets/stay_item.dart';
import 'package:remaining_days/widgets/settings_dialog.dart';
import 'package:remaining_days/widgets/stays_fab_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _storage = UserPreferences();
  RegionConfig _region = RegionConfig.defaultConfig();

  bool _scrollWasAtTop = true;

  @override
  void initState() {
    super.initState();
    _storage.readSelected().then(
          (value) => setState(() {
            if (value != null) _region = value;
          }),
        );
  }

  void _addStay(StayItem stayItem) {
    if (_region.stays.contains(stayItem)) return;

    setState(() {
      _region.stays.add(stayItem);
      _region.stays.sort(
        (range1, range2) =>
            _region.sortAscending ? range2.start.compareTo(range1.start) : range1.start.compareTo(range2.start),
      );
    });
    _storage.write(_region);
  }

  void _removeStay(StayItem stayItem) {
    setState(() {
      _region.stays.remove(stayItem);
    });
    _storage.write(_region);
  }

  void _sort() {
    _region.sortAscending = !_region.sortAscending;
    _storage.write(_region);

    setState(() {
      _region.stays.sort(
        (range1, range2) =>
            _region.sortAscending ? range2.start.compareTo(range1.start) : range1.start.compareTo(range2.start),
      );
    });
  }

  void _updateRegionSettings(Map<String, dynamic> settings) {
    setState(() {
      _region
        ..name = settings[Settings.regionName.name] as String
        ..rollingPeriod = int.parse(settings[Settings.rollingPeriod.name] as String)
        ..maxStay = int.parse(settings[Settings.maxStay.name] as String);
    });
    _storage.write(_region);
  }

  Future<void> _showDateRangePicker({StayItem? editingItem}) async {
    final picked = await showDateRangePickerDialog(context: context, initialDateRange: editingItem);

    if (picked != null) {
      if (editingItem != null) _removeStay(editingItem);
      _addStay(StayItem.ofDateTimeRange(picked));
    }
  }

  (int, String) _calculateRemainingDays(
    List<StayItem> entryExitDates, {
    required int maxStay,
    required int rollingRange,
  }) {
    (int, DateTimeRange?) usedDays;
    if ((usedDays = daysStayIn(entryExitDates, rollingRange: rollingRange, skipFutureDates: true)).$1 > maxStay) {
      final overStayRange = StayItem(
        start: DateTime(usedDays.$2!.end.year, usedDays.$2!.end.month, usedDays.$2!.end.day - (rollingRange - 1)),
        end: usedDays.$2!.end,
      );
      return (maxStay - usedDays.$1, 'overstay'.tr(args: [overStayRange.toString()]));
    }

    var remainingDays = 0;
    final today = DateTime.now();
    while (remainingDays < maxStay &&
        daysStayIn(
              entryExitDates + [StayItem(start: today, end: today.add(Duration(days: remainingDays)))],
              rollingRange: rollingRange,
              skipFutureDates: false,
            ).$1 <=
            maxStay) {
      ++remainingDays;
    }

    return (
      remainingDays,
      'stay_period'.tr(args: [DateFormat('d MMM y').format(today.add(Duration(days: remainingDays)))]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stays = _region.stays;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(_region.name),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => displayTextInputDialog(
              context: context,
              config: _region,
              onSave: _updateRegionSettings,
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).canvasColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onVerticalDragUpdate: DefaultBottomBarController.of(context).onDrag,
        onVerticalDragEnd: DefaultBottomBarController.of(context).onDragEnd,
        child: StaysFABWidget(
          hasStays: stays.isNotEmpty,
          ascending: _region.sortAscending,
          onPressed: () => DefaultBottomBarController.of(context).swap(),
          onSort: _sort,
        ),
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final collapsedHeight = constraints.maxHeight / 4;
          final expandedHeight = constraints.maxHeight / 3;
          return GestureDetector(
            onTap: _showDateRangePicker,
            child: BottomExpandableAppBar(
              appBarHeight: collapsedHeight,
              expandedHeight: expandedHeight,
              horizontalMargin: 0,
              shape: const AutomaticNotchedShape(RoundedRectangleBorder(), StadiumBorder(side: BorderSide())),
              expandedBody: NotificationListener<ScrollEndNotification>(
                onNotification: (scrollNotification) {
                  final bottomBarController = DefaultBottomBarController.of(context);
                  final metrics = scrollNotification.metrics;
                  final scrollIsAtTop = metrics.atEdge && metrics.pixels == 0;
                  if (_scrollWasAtTop && bottomBarController.isOpen && scrollIsAtTop) {
                    bottomBarController.close();
                  }
                  _scrollWasAtTop = scrollIsAtTop;
                  return true;
                },
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  itemCount: stays.isEmpty ? 1 : stays.length,
                  itemBuilder: (context, index) => stays.isEmpty
                      ? EmptyStayListItemWidget(addStay: _showDateRangePicker)
                      : StayListItemWidget(
                          stayListItem: stays[index],
                          onRemove: _removeStay,
                          onEdit: (item) => _showDateRangePicker(editingItem: item),
                          onAdd: _showDateRangePicker,
                          leadingWidget: Text('${stays.length - index}'),
                        ),
                  separatorBuilder: (context, index) => const Divider(),
                ),
              ),
            ),
          );
        },
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final remainingDays = _calculateRemainingDays(
            stays,
            maxStay: _region.maxStay,
            rollingRange: _region.rollingPeriod,
          );
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'day'.plural(remainingDays.$1),
                  style: TextStyle(
                    color: remainingDays.$1 < 0 ? Colors.red : null,
                    fontSize: max(constraints.maxHeight / 10, 28),
                  ),
                ),
                Text(
                  remainingDays.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: max(constraints.maxHeight / 24, 14)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
