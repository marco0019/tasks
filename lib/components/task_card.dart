import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks/models/models.dart';
import 'package:tasks/pages/pages.dart';
import 'package:tasks/providers/providers.dart';
import 'package:tasks/statics/global.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showBottomSheet(context),
      child: Container(
          decoration: BoxDecoration(
              color: GLOBAL.colors[task.color]
                  .withOpacity(task.expired() ? .5 : 1),
              borderRadius: const BorderRadius.all(Radius.circular(15))),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(10),
          child: Row(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_sharp,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                        '${task.delivery.hour}:${(task.delivery.minute > 9 ? '' : '0') + task.delivery.minute.toString()}'),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  //'svòkjsdflvhbfoqiuewhobwqkcjhsbdjcs dfviouih3ipuh0uhoiuh',
                  task.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const Spacer(),
            Transform.rotate(
                angle: -pi / 2,
                child: Transform.translate(
                  offset: const Offset(0, 40),
                  child: Container(
                      alignment: Alignment.center,
                      width: 100,
                      height: 40,
                      child: Column(
                        children: [
                          Divider(
                            color: context.watch<ThemeProvider>().isDarkTheme
                                ? Colors.grey[200]
                                : Colors.grey[800],
                          ),
                          Text(task.expired()
                              ? 'EXPIRED'
                              : task.isCompleted
                                  ? 'COMPLETED'
                                  : 'TODO'),
                        ],
                      )),
                )),
          ])),
    );
  }

  _showBottomSheet(BuildContext context) {
    final tasks = context.read<TaskProvider>();
    final notification = context.read<LocalNotification>();
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 340,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text(
                        task.title,
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    buttonBottomSheet(
                        context, !task.expired(), 'Task completed', null, () {
                      task.isCompleted = !task.isCompleted;
                      tasks.update(task.id, task);
                      tasks.initialize();
                      if (task.isCompleted) {
                        notification.fln.cancel(task.id);
                      } else {
                        notification.scheduleTask(task);
                      }
                      Navigator.pop(context);
                    }, Colors.blue, Colors.transparent),
                    const SizedBox(height: 10),
                    buttonBottomSheet(
                        context, !task.expired(), 'Modify task', null, () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TaskPage(task: task)))
                          .then((value) {
                        Navigator.pop(context);
                        if (value != null) {
                          if (value.advert != null) {
                            notification.reSchedule(value);
                          }
                          tasks.update(task.id, value);
                          tasks.initialize();
                        }
                      });
                    }, Colors.orangeAccent, Colors.transparent),
                    const SizedBox(height: 10),
                    buttonBottomSheet(context, true, 'Delete task',
                        null, () {
                      tasks.delete(task.id);
                      tasks.initialize();
                      Navigator.pop(context);
                    }, Colors.redAccent, Colors.transparent),
                    const Spacer(),
                    buttonBottomSheet(
                        context,
                        true,
                        'Close',
                        null,
                        () => Navigator.pop(context),
                        Colors.transparent,
                        Colors.grey),
                    const SizedBox(height: 10)
                  ],
                )),
          );
        });
  }

  buttonBottomSheet(BuildContext context, bool active, String label,
          IconData? icon, Function onClick, Color background, Color border) =>
      Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            border: Border.all(color: border),
            color: active ? background : Colors.grey,
            borderRadius: const BorderRadius.all(Radius.circular(15))),
        child: GestureDetector(
          onTap: () => active ? onClick() : null,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                  if (icon != null) Icon(icon)
                ],
              )),
        ),
      );
}
