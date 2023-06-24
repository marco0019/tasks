import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tasks/components/components.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:tasks/models/models.dart';
import 'package:tasks/pages/pages.dart';
import 'package:tasks/providers/providers.dart';
import 'package:tasks/statics/global.dart';

class CalendarTasks extends StatefulWidget {
  const CalendarTasks({super.key});

  @override
  State<CalendarTasks> createState() => _CalendarTasksState();
}

class _CalendarTasksState extends State<CalendarTasks> {
  late DateTime currentDate;
  final PageController _pageController = PageController();
  final PageController _taskPageController = PageController();
  final data = DateTime.now().add(Duration(days: 1 - DateTime.now().weekday));
  @override
  void initState() {
    super.initState();
    currentDate = data;
    final task = context.read<TaskProvider>();
    task.initialize();
    _taskPageController.addListener(() {
      setState(() => task.setCurrentTaskPage(_taskPageController.page! % 7));
      _pageController.jumpToPage(
        (_taskPageController.page! / 7).floor(),
        //duration: const Duration(milliseconds: 10),
        //curve: Curves.decelerate
      );
    });
    _pageController.addListener(() {
      var currentPage = currentDate.difference(data).inDays ~/ 7;
      if (currentPage == _pageController.page!.ceil()) {
        task.setCurrentTaskPage(task.currentTaskPage % 7, notify: true);
      } else {
        if (currentPage > _pageController.page!.ceil()) {
          task.setCurrentTaskPage(task.currentTaskPage + 7, notify: true);
        } else {
          task.setCurrentTaskPage(task.currentTaskPage - 7, notify: true);
        }
      }
      //debugPrint(currentPage.toString());
      /*debugPrint((_pages[0].currentContext!.findRenderObject() as RenderBox)
          .localToGlobal(Offset.zero)
          .dx
          .toString());*/
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _taskPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();
    return Scaffold(
        appBar: AppBar(
          leading: const ChangeTheme(),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      tasks.setExpiredTask();
                      if (tasks.expiredTasks.isNotEmpty) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ExpiredTasks()));
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios)),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    showDatePicker(
                            context: context,
                            initialDate: currentDate,
                            firstDate: data,
                            lastDate:
                                data.add(Duration(days: GLOBAL.weeks * 7)))
                        .then((value) {
                      if (value != null) {
                        setState(() => currentDate = value);
                        _pageController
                            .jumpToPage(value.difference(data).inDays ~/ 7);
                        _taskPageController.animateToPage(
                            currentDate.difference(data).inDays + 1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.decelerate);
                        tasks.setCurrentTaskPage(value.weekday - 1,
                            notify: true);
                      }
                    });
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          '${GLOBAL.month[currentDate.month - 1].toUpperCase()} ${currentDate.day}, ${currentDate.year}',
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold))),
                ),
              ],
            ),
            SizedBox(
              //color: Colors.red,
              height: 70,
              child: Stack(
                children: [
                  Positioned(
                      top: 0,
                      left: MediaQuery.of(context).size.width /
                          7 *
                          tasks.currentTaskPage,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10))),
                        width: MediaQuery.of(context).size.width / 7,
                        height: 70,
                      )),
                  PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.horizontal,
                      itemCount: GLOBAL.weeks,
                      itemBuilder: (context, index) {
                        return Row(children: [
                          for (int i = 0; i < 7; i++)
                            card(data.add(Duration(days: index * 7 + i)),
                                index * 7 + i)
                        ]);
                      }),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: PageView.builder(
                controller: _taskPageController,
                onPageChanged: (value) => setState(
                    () => currentDate = data.add(Duration(days: value))),
                itemCount: GLOBAL.weeks * 7,
                itemBuilder: (context, index) {
                  List<Task> taskOfDay = tasks.getTasksFromDate(
                      date: data.add(Duration(days: index)));
                  if (taskOfDay.isEmpty) {
                    return const EmptyTaskPage(
                      title: 'No tasks in this day',
                      subtitle:
                          'In this day there aren\'t any tasks to complete',
                    );
                  }
                  return ListView.builder(
                    itemCount: taskOfDay.length,
                    itemBuilder: (context, index) =>
                        AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 500),
                            child: SlideAnimation(
                              child: FadeInAnimation(
                                  child: TaskTile(task: taskOfDay[index])),
                            )),
                  );
                },
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TaskPage()))
                    .then((value) {
                  if (value != null) {
                    setState(() => currentDate = value.delivery);
                    _pageController.jumpToPage(
                        value.delivery.difference(data).inDays ~/ 7);
                    _taskPageController.animateToPage(
                        currentDate.difference(data).inDays + 1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.decelerate);
                    tasks.setCurrentTaskPage(value.delivery.weekday - 1.0,
                        notify: true);
                    tasks.insert(value as Task).then((taskId) =>
                        value.advert == null
                            ? null
                            : context
                                .read<LocalNotification>()
                                .scheduleTask(value));
                    tasks.initialize();
                  }
                }),
            child: const Icon(Icons.add)));
  }

  card(DateTime date, int index) => Expanded(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: GLOBAL.isSameDay(date, DateTime.now()) &&
                      !GLOBAL.isSameDay(currentDate, DateTime.now())
                  ? Colors.grey.withOpacity(.15)
                  : null),
          child: GestureDetector(
            onTap: () => setState(() {
              context.read<TaskProvider>().setCurrentTaskPage(
                  (currentDate.weekday - 1).toDouble(),
                  notify: true);
              currentDate = date;
              _taskPageController.animateToPage(index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.decelerate);
            }),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Text(date.day.toString(),
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: GLOBAL.isSameDay(date, currentDate)
                              ? Colors.white
                              : Colors.grey[500])),
                  Text(
                    GLOBAL.days[date.weekday - 1].toUpperCase(),
                    style: TextStyle(
                        color: GLOBAL.isSameDay(date, currentDate)
                            ? Colors.white
                            : Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
