import 'package:flutter/material.dart';

import 'bottom_bar_widget/controller.dart';

class StaysFABWidget extends StatelessWidget {
  const StaysFABWidget(
      {Key? key,
      required this.hasStays,
      required this.onAddStay,
      required this.onPressed})
      : super(key: key);

  final bool hasStays;
  final VoidCallback onAddStay;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
        icon: hasStays
            ? IconButton(
                onPressed: onAddStay,
                icon: const Icon(Icons.add_circle_outline),
              )
            : const SizedBox(width: 27),
        label: Row(
          children: [
            const Text('Stays', style: TextStyle(fontSize: 18)),
            AnimatedBuilder(
              animation: DefaultBottomBarController.of(context).state,
              builder: (context, child) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(
                  1,
                  DefaultBottomBarController.of(context).state.value * 2 - 1,
                  1,
                ),
                child: child,
              ),
              child: const RotatedBox(
                quarterTurns: 1,
                child: Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(width: 27)
          ],
        ),
        elevation: 2,
        onPressed: onPressed);
  }
}
