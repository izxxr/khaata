import 'package:flutter/material.dart';

Future<DateTime?> showDateTimePickerModal(
  BuildContext context,
  {
    DateTime? initialDateTime
  }
) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDateTime ?? DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  if (pickedDate == null || !context.mounted) return initialDateTime;

  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDateTime ?? DateTime.now()),
  );

  if (pickedTime == null) return pickedDate; // User canceled

  return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
}
