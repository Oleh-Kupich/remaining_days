import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StaysFABWidget extends StatelessWidget {
  const StaysFABWidget(
      {required this.hasStays, required this.onPressed, required this.onSort, required this.ascending, super.key,});

  final bool hasStays;
  final bool ascending;
  final VoidCallback onPressed;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
        label: Row(
          children: [
            const SizedBox(width: 28),
            const Text('stays', style: TextStyle(fontSize: 18)).tr(),
            if (hasStays) IconButton(
                    onPressed: onSort,
                    icon: Icon(
                      ascending ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                      size: 32,
                    ),) else const SizedBox(width: 28),
          ],
        ),
        elevation: 2,
        onPressed: onPressed,);
  }
}
