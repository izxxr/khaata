import 'package:flutter/material.dart';


/// Helper to chain Flutter's showDatePicker and showTimePicker.
/// 
/// Returns complete DateTime object with both date and time information.
/// 
/// If the user closes modal without choosing time, the chosen date is returned
/// with 00:00 time.
/// 
/// If the user closes without choosing date, returns initialDate (which could be
/// null if not provided).
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
