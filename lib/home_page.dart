import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:remaining_days/math/remaining_days.dart';
import 'package:remaining_days/models/region_config.dart';
import 'package:remaining_days/models/stay_item.dart';
import 'package:remaining_days/storage/user_preferences.dart';
import 'package:remaining_days/widgets/bottom_bar_widget/controller.dart';
import 'package:remaining_days/widgets/bottom_bar_widget/widget.dart';
import 'package:remaining_days/widgets/date_range_picker_widget.dart';
import 'package:remaining_days/widgets/list_item_widgets/empty_stay.dart';
import 'package:remaining_days/widgets/list_item_widgets/stay_item.dart';
import 'package:remaining_days/widgets/stays_fab_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = UserPreferences();
  RegionConfig? region;

  bool scrollWasAtTop = true;

  @override
  void initState() {
    super.initState();
    storage.readSelected().then((value) => setState(() { region = value; }));
  }

  void addStay(StayItem stayItem) {
    final config = region;
    if (config == null) return;
    if (config.stays.contains(stayItem)) return;

    setState(() {
      config.stays.add(stayItem);
      config.stays.sort((range1, range2) =>
          config.sortAscending ? range2.start.compareTo(range1.start) : range1.start.compareTo(range2.start),);
    });
    storage.write(config);
  }

  void removeStay(StayItem stayItem) {
    final config = region;
    if (config == null) return;
    setState(() {
      config.stays.remove(stayItem);
    });
    storage.write(config);
  }

  void sort() {
    final config = region;
    if (config == null) return;

    config.sortAscending = !config.sortAscending;
    storage.write(config);

    setState(() {
      config.stays.sort((range1, range2) =>
          config.sortAscending ? range2.start.compareTo(range1.start) : range1.start.compareTo(range2.start),);
    });
  }

  Future<void> showDateRangePicker({StayItem? editingItem}) async {
    final picked = await showDateRangePickerDialog(context: context, initialDateRange: editingItem);

    if (picked != null) {
      if (editingItem != null) removeStay(editingItem);
      addStay(StayItem.ofDateTimeRange(picked));
    }
  }

  (int, String) calculateRemainingDays(List<StayItem> entryExitDates,
      {required int maxStay, required int rollingRange,}) {
    (int, DateTimeRange?) usedDays;
    if ((usedDays = daysStayIn(entryExitDates, rollingRange: rollingRange, skipFutureDates: true)).$1 > maxStay) {
      final overStayRange = StayItem(
          start: DateTime(usedDays.$2!.end.year, usedDays.$2!.end.month, usedDays.$2!.end.day - (rollingRange - 1)),
          end: usedDays.$2!.end,);
      return (maxStay - usedDays.$1, 'overstay'.tr(args: [overStayRange.toString()]));
    }

    var remainingDays = 0;
    final today = DateTime.now();
    while (remainingDays < maxStay &&
        daysStayIn(entryExitDates + [StayItem(start: today, end: today.add(Duration(days: remainingDays)))],
                    rollingRange: rollingRange, skipFutureDates: false,)
                .$1 <=
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
    final stays = region?.stays ?? [];
    return Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: GestureDetector(
            onVerticalDragUpdate: DefaultBottomBarController.of(context).onDrag,
            onVerticalDragEnd: DefaultBottomBarController.of(context).onDragEnd,
            child: StaysFABWidget(
              hasStays: stays.isNotEmpty,
              ascending: region?.sortAscending ?? true,
              onPressed: () => DefaultBottomBarController.of(context).swap(),
              onSort: sort,
            ),),
        bottomNavigationBar: GestureDetector(
            onTap: showDateRangePicker,
            child: BottomExpandableAppBar(
                appBarHeight: 200,
                expandedHeight: 300,
                horizontalMargin: 0,
                shape: const AutomaticNotchedShape(RoundedRectangleBorder(), StadiumBorder(side: BorderSide())),
                expandedBody: NotificationListener<ScrollEndNotification>(
                  onNotification: (scrollNotification) {
                    final bottomBarController = DefaultBottomBarController.of(context);
                    final metrics = scrollNotification.metrics;
                    final scrollIsAtTop = metrics.atEdge && metrics.pixels == 0;
                    if (scrollWasAtTop && bottomBarController.isOpen && scrollIsAtTop) {
                      bottomBarController.close();
                    }
                    scrollWasAtTop = scrollIsAtTop;
                    return true;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                    itemCount: stays.isEmpty ? 1 : stays.length,
                    itemBuilder: (context, index) => stays.isEmpty
                        ? EmptyStayListItemWidget(addStay: showDateRangePicker)
                        : StayListItemWidget(
                            stayListItem: stays[index],
                            onRemove: removeStay,
                            onEdit: (item) => showDateRangePicker(editingItem: item),
                            onAdd: showDateRangePicker,
                            leadingWidget: Text('${stays.length - index}'),
                          ),
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                ),),),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final remainingDays =
                calculateRemainingDays(
                    stays,
                    maxStay: region?.maxStay ?? 90,
                    rollingRange: region?.rollingPeriod ?? 180,
                );
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'day'.plural(remainingDays.$1),
                        style: TextStyle(
                            color: remainingDays.$1 < 0 ? Colors.red : null, fontSize: max(constraints.maxHeight / 10, 28),),
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
