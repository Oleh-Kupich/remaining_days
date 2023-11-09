import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StaysFABWidget extends StatelessWidget {
  const StaysFABWidget({
    required this.hasStays,
    required this.onPressed,
    required this.onAdd,
    required this.onSort,
    required this.ascending,
    super.key,
  });

  final bool hasStays;
  final bool ascending;
  final VoidCallback onPressed;
  final VoidCallback onSort;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      label: Row(
        children: [
          if (hasStays)
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
            ),
          const SizedBox(width: 16),
          const Text('stays', style: TextStyle(fontSize: 18)).tr(),
          const SizedBox(width: 16),
          if (hasStays)
            IconButton(
              onPressed: onSort,
              icon: Icon(
                ascending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 28,
              ),
            ),
        ],
      ),
      elevation: 2,
      onPressed: onPressed,
    );
  }
}
