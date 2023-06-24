import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = true;
  bool get isDarkTheme => _isDarkTheme;
  set isDarkTheme(bool value) {
    _isDarkTheme = value;
    notifyListeners();
  }

  toggle() {
    isDarkTheme = !isDarkTheme;
    notifyListeners();
  }
}
