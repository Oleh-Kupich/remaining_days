import 'package:flutter/material.dart';

Future<DateTimeRange?> showDateRangePickerDialog({
  required BuildContext context,
}) =>
    showDateRangePicker(
        context: context,
        locale: Localizations.localeOf(context),
        keyboardType: TextInputType.text,
        initialEntryMode: DatePickerEntryMode.calendar,
        confirmText: "Save",
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        builder: (context, child) {
          return Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(context)
                    .textTheme
                    .copyWith(headlineLarge: const TextStyle(fontSize: 20)),
                colorScheme: Theme.of(context)
                    .colorScheme
                    .copyWith(surfaceTint: Colors.white),
              ),
              child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: child)));
        });
