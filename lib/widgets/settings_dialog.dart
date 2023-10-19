
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:remaining_days/models/region_config.dart';

enum Settings { regionName, rollingPeriod, maxStay }

Future<void> displayTextInputDialog({
  required BuildContext context,
  required RegionConfig config,
  required void Function(Map<String, dynamic>) onSave,
}) async {
  final formKey = GlobalKey<FormBuilderState>();
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () { Navigator.pop(context); },
                icon: const Icon(Icons.clear),
              ),
              const Text('Region', textAlign: TextAlign.center,),
              const SizedBox(width: 48),
            ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        content: FormBuilder(
          key: formKey,
          child:  SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderTextField(
                  name: Settings.regionName.name,
                  initialValue: config.name,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.maxLength(120),
                  ]),
                ),
                FormBuilderTextField(
                  name: Settings.rollingPeriod.name,
                  initialValue: config.rollingPeriod.toString(),
                  decoration: const InputDecoration(
                      labelText: 'Period',
                      suffixText: ' days',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.integer(),
                  ]),
                ),
                FormBuilderTextField(
                  name: Settings.maxStay.name,
                  initialValue: config.maxStay.toString(),
                  decoration: const InputDecoration(
                      labelText: 'Maximum stay',
                      suffixText: ' days',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.integer(),
                    (value) {
                      final maxStay = int.parse(value!);
                      final rollingPeriod = int.parse(formKey.currentState!.instantValue[Settings.rollingPeriod.name] as String);
                      if (maxStay > rollingPeriod) return 'Value must be less or equal $rollingPeriod';
                      return null;
                    },
                  ]),
                  onSaved: (value) {},
                ),
                MaterialButton(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      onSave(formKey.currentState!.instantValue);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
