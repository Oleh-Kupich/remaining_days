import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<DateTimeRange?> showDateRangePickerDialog({
  required BuildContext context,
  DateTimeRange? initialDateRange,
}) =>
    showDateRangePicker(
        context: context,
        initialDateRange: initialDateRange,
        locale: Localizations.localeOf(context),
        keyboardType: TextInputType.text,
        confirmText: 'save'.tr(),
        firstDate: DateTime(DateTime.now().year - 2),
        lastDate: DateTime(DateTime.now().year + 2),
        builder: (context, child) {
          return Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(context).textTheme.copyWith(headlineLarge: const TextStyle(fontSize: 20)),
                colorScheme: Theme.of(context).colorScheme.copyWith(surfaceTint: Colors.white),
              ),
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: ClipRRect(borderRadius: BorderRadius.circular(20), child: child),),);
        },);
