
import 'package:flutter/material.dart';

class GLOBAL {
  static List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static List<String> month = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  static int weeks = 108;
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  static final List<Color> colors = [
    Colors.blue,
    Colors.redAccent,
    Colors.orangeAccent
  ];
}
