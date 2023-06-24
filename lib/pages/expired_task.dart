import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:tasks/components/components.dart';
import 'package:tasks/providers/task_provider.dart';

class ExpiredTasks extends StatelessWidget {
  const ExpiredTasks({super.key});

  @override
  Widget build(BuildContext context) {
    final task = context.watch<TaskProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Expired tasks')),
      body: task.expiredTasks.isEmpty
          ? const Center(
              child: EmptyTaskPage(
                  title: 'No tasks expired',
                  subtitle: 'There aren\'t any tasks expired'),
            )
          : ListView.builder(
              itemCount: task.expiredTasks.length,
              itemBuilder: (context, index) =>
                  AnimationConfiguration.staggeredList(
                      position: index,
                      child: SlideAnimation(
                          child: FadeInAnimation(
                              child: TaskTile(
                        task: task.expiredTasks[index],
                      ))))),
    );
  }
}
