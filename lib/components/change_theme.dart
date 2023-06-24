import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks/providers/providers.dart';

class ChangeTheme extends StatelessWidget {
  const ChangeTheme({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return IconButton(
        onPressed: () => theme.toggle(),
        icon: Icon(theme.isDarkTheme ? Icons.sunny : Icons.mode_night));
  }
}
