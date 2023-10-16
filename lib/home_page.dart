import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remaining_days/remaining_days_math.dart';
import 'package:remaining_days/stay_item.dart';
import 'package:remaining_days/list_item_widgets/stay_item.dart';
import 'package:remaining_days/stays_fab_widget.dart';

import 'bottom_bar_widget/widget.dart';
import 'date_range_picker_widget.dart';
import 'list_item_widgets/empty_stay.dart';
import 'bottom_bar_widget/controller.dart';

void main() {
  runApp(const RemainingDaysApp());
}

class RemainingDaysApp extends StatelessWidget {
  const RemainingDaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.orangeAccent);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        useMaterial3: true,
      ),
      home: DefaultBottomBarController(
        child: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool scrollWasAtTop = true;

  final stays = List<StayItem>.empty(growable: true);
  var ascending = true;

  void addStay(final StayItem stayItem) {
    if (stays.contains(stayItem)) return;
    setState(() {
      stays.add(stayItem);
      stays.sort(
          (range1, range2) => ascending ? range2.start.compareTo(range1.start) : range1.start.compareTo(range2.start));
    });
  }

  void sort() {
    ascending = !ascending;
    setState(() {
      stays.sort(
          (range1, range2) => ascending ? range2.start.compareTo(range1.start) : range1.start.compareTo(range2.start));
    });
  }

  void removeStay(final StayItem stayItem) {
    setState(() {
      stays.remove(stayItem);
    });
  }

  void showDateRangePicker({StayItem? editingItem}) async {
    DateTimeRange? picked = await showDateRangePickerDialog(context: context, initialDateRange: editingItem);

    if (picked != null) {
      if (editingItem != null) removeStay(editingItem);
      addStay(StayItem.ofDateTimeRange(picked));
    }
  }

  (int, String) calculateRemainingDays(final List<StayItem> entryExitDates,
      {int maxStay = 90, int rollingRange = 180}) {
    (int, DateTimeRange?) usedDays;
    if ((usedDays = daysStayIn(entryExitDates, rollingRange: rollingRange, skipFuture: true)).$1 > maxStay) {
      final overStayRange = StayItem(
          start: DateTime(usedDays.$2!.end.year, usedDays.$2!.end.month, usedDays.$2!.end.day - (rollingRange - 1)),
          end: usedDays.$2!.end);
      return (maxStay - usedDays.$1, 'Overstay in the period \n$overStayRange');
    }

    int remainingDays = 0;
    DateTime today = DateTime.now();
    while (remainingDays < maxStay &&
        daysStayIn(entryExitDates + [StayItem(start: today, end: today.add(Duration(days: remainingDays)))],
                    rollingRange: rollingRange)
                .$1 <=
            maxStay) {
      ++remainingDays;
    }

    return (
      remainingDays,
      'from Today to ${DateFormat('d MMM y').format(today.add(Duration(days: remainingDays)))}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: GestureDetector(
            onVerticalDragUpdate: DefaultBottomBarController.of(context).onDrag,
            onVerticalDragEnd: DefaultBottomBarController.of(context).onDragEnd,
            child: StaysFABWidget(
              hasStays: stays.isNotEmpty,
              ascending: ascending,
              onPressed: () => DefaultBottomBarController.of(context).swap(),
              onSort: () => sort(),
            )),
        //
        // Actual expandable bottom bar
        bottomNavigationBar: BottomExpandableAppBar(
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
                    ? EmptyStayListItemWidget(addStay: () => showDateRangePicker())
                    : StayListItemWidget(
                        stayListItem: stays[index],
                        onRemove: (item) => removeStay(item),
                        onEdit: (item) => showDateRangePicker(editingItem: item),
                        onAdd: () => showDateRangePicker(),
                        leadingWidget: Text('${stays.length - index}'),
                      ),
                separatorBuilder: (context, index) => const Divider(),
              ),
            )),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final (int, String) remainingDays = calculateRemainingDays(stays);
            return Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                '${remainingDays.$1} ${remainingDays.$1 == 1 ? 'day' : 'days'}',
                style: TextStyle(
                    color: remainingDays.$1 < 0 ? Colors.red : null, fontSize: max(constraints.maxHeight / 8, 28)),
              ),
              Text(
                remainingDays.$2,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ]));
          },
        ));
  }
}
