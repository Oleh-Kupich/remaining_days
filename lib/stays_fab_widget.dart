import 'package:flutter/material.dart';

class StaysFABWidget extends StatelessWidget {
  const StaysFABWidget(
      {Key? key, required this.hasStays, required this.onPressed, required this.onSort, required this.ascending})
      : super(key: key);

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
            const Text('Stays', style: TextStyle(fontSize: 18)),
            hasStays
                ? IconButton(
                    onPressed: onSort,
                    icon: Icon(
                      ascending ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                      size: 32,
                    ))
                : const SizedBox(width: 20),
          ],
        ),
        elevation: 2,
        onPressed: onPressed);
  }
}
