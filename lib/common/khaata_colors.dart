import 'package:flutter/material.dart';

/// Enum describing the color of an account.
enum KhaataColors {
  slate(0, Color(0xFF64748B)),
  blue(1, Color(0xFF3B82F6)),
  sky(2, Color(0xFF0EA5E9)),
  green(3, Color(0xFF22C55E)),
  emerald(4, Color(0xFF10B981)),
  amber(5, Color(0xFFF59E0B)),
  orange(6, Color(0xFFF97316)),
  red(7, Color(0xFFEF4444)),
  rose(8, Color(0xFFF43F5E)),
  violet(9, Color(0xFF8B5CF6)),
  fuchsia(10, Color(0xFFD946EF)),
  teal(11, Color(0xFF14B8A6));

  const KhaataColors(this.id, this.color);

  final int id;
  final Color color;

  static KhaataColors fromId(int id) {
    return values.firstWhere((color) => color.id == id);
  }
}
