import 'package:flutter/services.dart';


/// Text formatter for amount fields
/// 
/// Allows non-negative amounts with a maximum of 2 decimal places.
final amountFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
  final value = newValue.text;

  if (value.isEmpty) {
    return newValue;
  }

  if (RegExp(r'^\d+(?:\.\d{0,2})?$').hasMatch(value)) {
    return newValue;
  }

  return oldValue;
});
