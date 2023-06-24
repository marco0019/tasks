import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tasks/models/task.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';
//import 'package:timezone/timezone.dart';

class LocalNotification with ChangeNotifier {
  final String channelId;
  final String channelName;
  final settings =
      const InitializationSettings(iOS: DarwinInitializationSettings());
  final FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();
  LocalNotification({required this.channelId, required this.channelName});

  Future<void> initialize() async {
    initializeTimeZones();
    await fln.initialize(
        const InitializationSettings(
            android: AndroidInitializationSettings('mipmap/ic_launcher'),
            iOS: DarwinInitializationSettings()),
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse);
  }

  Future<NotificationDetails> _notificationDetails() async {
    return NotificationDetails(
        android: AndroidNotificationDetails(channelId, channelName,
            channelDescription: 'description',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true),
        iOS: const DarwinNotificationDetails());
  }

  Future<void> show(
      {required int id, required String title, required String body}) async {
    final details = await _notificationDetails();
    await fln.show(id, title, body, details);
  }

  Future<void> schedule(
      {required int id,
      required String title,
      required String body,
      required DateTime eventDate}) async {
    final details = await _notificationDetails();
    await fln.zonedSchedule(
        id, title, body, TZDateTime.from(eventDate, local), details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> scheduleTask(Task task) async {
    await schedule(
        id: task.id,
        title: task.title,
        body:
            '${task.advert!.inMinutes} minutes to complete the task \'${task.title}\'',
        eventDate: task.delivery.add(task.advert!));
  }

  Future<void> reSchedule(Task task) async {
    fln.cancel(task.id);
    await scheduleTask(task);
  }

  _onDidReceiveNotificationResponse(NotificationResponse response) {}
}
