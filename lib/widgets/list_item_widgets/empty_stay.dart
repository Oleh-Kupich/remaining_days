import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EmptyStayListItemWidget extends StatelessWidget {
  const EmptyStayListItemWidget({
    required this.addStay, super.key,
  });

  final VoidCallback addStay;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: addStay,
      child: SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add),
              const SizedBox(width: 8),
              const Text('add_stay').tr(),
            ],
          ),),
    );
  }
}
