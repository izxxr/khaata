import 'package:flutter/services.dart';


TextInputFormatter getAmountFormatter() {
  return TextInputFormatter.withFunction((oldValue, newValue) {
    final value = newValue.text;

    if (value.isEmpty) {
      return newValue;
    }

    if (RegExp(r'^\d+(?:\.\d{0,2})?$').hasMatch(value)) {
      return newValue;
    }

    return oldValue;
  });
}
