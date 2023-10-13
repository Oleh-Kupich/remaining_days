import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:remaining_days/stay_item.dart';

typedef RemoveActionCallback = void Function(StayItem item);
typedef EditActionCallback = void Function(StayItem item);

class StayListItemWidget extends StatelessWidget {
  const StayListItemWidget(
      {Key? key,
      required this.stayListItem,
      required this.onRemove,
      required this.onEdit,
      this.leadingWidget})
      : super(key: key);

  final StayItem stayListItem;
  final Widget? leadingWidget;
  final RemoveActionCallback onRemove;
  final EditActionCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Slidable(
        key: Key(stayListItem.key),
        // The start action pane is the one at the left or the top side.
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.4,
          dismissible: DismissiblePane(onDismissed: () {
            onRemove(stayListItem);
          }),
          children: [
            SlidableAction(
              onPressed: (_) {
                onRemove(stayListItem);
              },
              autoClose: false,
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              icon: Icons.delete_forever_rounded,
              label: 'Delete',
            ),
          ],
        ),
        // The end action pane is the one at the right or the bottom side.
        endActionPane: ActionPane(
          extentRatio: 0.4,
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (_) {
                onEdit(stayListItem);
              },
              backgroundColor: Colors.green,
              icon: Icons.edit,
              label: 'Edit',
            ),
          ],
        ),
        child: ListTile(
          leading: leadingWidget,
          title: Text(stayListItem.toString()),
          onLongPress: () {
            onEdit(stayListItem);
          },
        ));
  }
}
