import 'package:flutter/material.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/statics/global.dart';
import 'package:tasks/statics/local_storage.dart';

class TaskProvider with ChangeNotifier {
  double currentTaskPage = .0;
  List<Task> tasks = [];
  List<Task> expiredTasks = [];
  bool isInitialized = false;
  Future<void> initialize() async {
    await LocalStorage.db.query('Tasks', orderBy: 'delivery').then((value) {
      tasks.clear();
      for (final item in value) {
        tasks.add(Task.fromJSON(item));
      }
      isInitialized = true;
      notifyListeners();
    });
  }

  void setCurrentTaskPage(double value, {bool notify = false}) {
    currentTaskPage = value;
    if (notify) notifyListeners();
  }

  Future<int> insert(Task task) async {
    isInitialized = false;
    return await LocalStorage.db.insert('Tasks', {
      'title': task.title,
      'description': task.description,
      'color': task.color,
      'isCompleted': task.isCompleted ? 1 : 0,
      'delivery': task.delivery.toIso8601String()
    });
  }

  List<Task> getTasksFromDate({required DateTime date}) {
    if (!isInitialized) initialize();
    List<Task> taskFromDate = [];
    for (final task in tasks) {
      if (GLOBAL.isSameDay(date, task.delivery) || task.repeat.contains(date.weekday.toString())) {
        taskFromDate.add(task);
      }
    }
    return taskFromDate;
  }

  Future<void> setExpiredTask() async {
    await initialize().then((value) {
      expiredTasks.clear();
      for (var task in tasks) {
        if (task.expired()) {
          expiredTasks.add(task);
        }
      }
      notifyListeners();
    });
  }

  Future<void> update(int id, Task newTask) async {
    isInitialized = false;
    await LocalStorage.db.update(
        'Tasks',
        {
          'title': newTask.title,
          'description': newTask.description,
          'color': newTask.color,
          'isCompleted': newTask.isCompleted ? 1 : 0,
          'delivery': newTask.delivery.toIso8601String()
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    isInitialized = false;
    await LocalStorage.db.delete('Tasks', where: 'id = ?', whereArgs: [id]);
  }
}
