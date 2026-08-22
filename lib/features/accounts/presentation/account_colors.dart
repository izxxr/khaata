import 'package:flutter/material.dart';
import 'package:khaata/features/accounts/models/accounts.dart';


/// Provides definition of colors for AccountColorValues enum from /features/models/accounts.dart
class AccountColors {
  static const blue = Color(0xFF3B82F6);
  static const sky = Color(0xFF0EA5E9);
  static const green = Color(0xFF22C55E);
  static const emerald = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
  static const orange = Color(0xFFF97316);
  static const red = Color(0xFFEF4444);
  static const rose = Color(0xFFF43F5E);
  static const violet = Color(0xFF8B5CF6);
  static const fuchsia = Color(0xFFD946EF);
  static const teal = Color(0xFF14B8A6);
  static const slate = Color(0xFF64748B);

  /// IMPORTANT: The order should not be changed. New colors must be added at the
  /// end of this list.
  static const all = [
    blue,
    sky,
    green,
    emerald,
    amber,
    orange,
    red,
    rose,
    violet,
    fuchsia,
    teal,
    slate,
  ];

  /// Maps AccountColorValues enum to corresponding Color instance.
  static Color fromEnum(AccountColorValues value) {
    return all[value.index];
  }
}
