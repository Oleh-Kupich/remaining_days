import 'package:flutter/material.dart';

class EmptyStayListItemWidget extends StatelessWidget {
  const EmptyStayListItemWidget({
    Key? key,
    required this.addStay,
  }) : super(key: key);

  final VoidCallback addStay;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: addStay,
      child: const SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline),
              SizedBox(width: 8),
              Text('Add stay by taping here'),
            ],
          )),
    );
  }
}
