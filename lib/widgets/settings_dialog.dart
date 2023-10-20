import 'package:easy_localization/easy_localization.dart';
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
      var period = config.rollingPeriod;
      var maxStay = config.maxStay;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            titlePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.clear),
                ),
                const Text(
                  'region',
                  textAlign: TextAlign.center,
                ).tr(),
                const SizedBox(width: 48),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            content: FormBuilder(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FormBuilderTextField(
                      name: Settings.regionName.name,
                      initialValue: config.name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'name'.tr(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.maxLength(120),
                      ]),
                    ),
                    FormBuilderTextField(
                      name: Settings.rollingPeriod.name,
                      initialValue: config.rollingPeriod.toString(),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'period'.tr(),
                        suffixText: 'day_suffix'.plural(period),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.integer(),
                        FormBuilderValidators.max(1000),
                      ]),
                      onChanged: (value) {
                        if (value == null) return;
                        final newPeriod = int.tryParse(value);
                        if (newPeriod == null) return;
                        setState(() {
                          period = newPeriod;
                        });
                      },
                    ),
                    FormBuilderTextField(
                      name: Settings.maxStay.name,
                      initialValue: config.maxStay.toString(),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'maximum_stay'.tr(),
                        suffixText: 'day_suffix'.plural(maxStay),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.integer(),
                        FormBuilderValidators.max(period),
                      ]),
                      onChanged: (value) {
                        if (value == null) return;
                        final newMaxStay = int.tryParse(value);
                        if (newMaxStay == null) return;
                        setState(() {
                          maxStay = newMaxStay;
                        });
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.all(12),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            onSave(formKey.currentState!.instantValue);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('save').tr(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
