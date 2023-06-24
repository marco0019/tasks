import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks/pages/calendar_mode.dart';
import 'package:tasks/providers/local_notification.dart';
import 'package:tasks/providers/task_provider.dart';
import 'package:tasks/providers/theme.dart';
import 'package:tasks/statics/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.initDB();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(
        create: (_) => LocalNotification(
            channelId: 'channelId', channelName: 'channelName')),
    ChangeNotifierProvider(create: (_) => TaskProvider())
  ], child: const Main()));
}

void _onDidiReceiveNotification(
    int id, String? title, String? body, String? payload) {}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  void initState() {
    context.read<LocalNotification>().initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: context.watch<ThemeProvider>().isDarkTheme
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const CalendarTasks(),
    );
  }
}
