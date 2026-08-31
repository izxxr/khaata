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


Future<(DateTime, DateTime)?> showDateRangePicker(BuildContext context) async {
  final DateTime? start = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    helpText: "Pick starting date"
  );

  if (start == null || !context.mounted) return null;

  final DateTime? end = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    selectableDayPredicate: (day) => day.isAfter(start),
    helpText: "Pick ending date"
  );

  if (end == null) return (start, DateTime.now()); // User canceled

  return (start, end);
}
