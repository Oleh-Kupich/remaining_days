import 'dart:math';

import 'package:flutter/material.dart';
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

  void addStay(final StayItem stayItem) {
    setState(() {
      stays.add(stayItem);
      stays.sort((range1, range2) => range2.start.compareTo(range1.end));
    });
  }

  void removeStay(final StayItem stayItem) {
    setState(() {
      stays.remove(stayItem);
    });
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
              onPressed: () => DefaultBottomBarController.of(context).swap(),
              onAddStay: () async {
                DateTimeRange? picked =
                    await showDateRangePickerDialog(context: context);
                if (picked != null) {
                  addStay(StayItem.ofDateTimeRange(picked));
                }
              }),
        ),
        //
        // Actual expandable bottom bar
        bottomNavigationBar: BottomExpandableAppBar(
            appBarHeight: 200,
            expandedHeight: 300,
            horizontalMargin: 0,
            shape: const AutomaticNotchedShape(
                RoundedRectangleBorder(), StadiumBorder(side: BorderSide())),
            expandedBody: NotificationListener<ScrollEndNotification>(
              onNotification: (scrollNotification) {
                final bottomBarController =
                    DefaultBottomBarController.of(context);
                final metrics = scrollNotification.metrics;
                final scrollIsAtTop = metrics.atEdge && metrics.pixels == 0;
                if (scrollWasAtTop &&
                    bottomBarController.isOpen &&
                    scrollIsAtTop) {
                  bottomBarController.close();
                }
                scrollWasAtTop = scrollIsAtTop;
                return true;
              },
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                itemCount: stays.isEmpty ? 1 : stays.length,
                itemBuilder: (context, index) => stays.isEmpty
                    ? EmptyStayListItemWidget(
                        addStay: () async {
                          DateTimeRange? picked =
                              await showDateRangePickerDialog(context: context);
                          if (picked != null) {
                            addStay(StayItem.ofDateTimeRange(picked));
                          }
                        },
                      )
                    : StayListItemWidget(
                        stayListItem: stays[index],
                        onRemove: (item) => removeStay(item),
                        onEdit: (_) {},
                        leadingWidget: Text('${stays.length - index}'),
                      ),
                separatorBuilder: (context, index) => const Divider(),
              ),
            )),
        body: Center(child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Text(
              '90 days',
              style: TextStyle(fontSize: max(constraints.maxHeight / 8, 28)),
            );
          },
        )));
  }
}
