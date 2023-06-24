import 'package:flutter/material.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/statics/global.dart';

class TaskPage extends StatefulWidget {
  final Task? task;
  const TaskPage({super.key, this.task});
  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isCompleted = false;
  DateTime? targetDate;
  bool errorMessageDate = false;
  int? dropdownValue;
  List<int?> minutesRange = [null, 5, 10, 15, 30, 60];
  int currentColor = 0;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      setState(() {
        _titleController.text = widget.task!.title;
        _descriptionController.text = widget.task!.description;
        _isCompleted = widget.task!.isCompleted;
        targetDate = widget.task!.delivery;
        currentColor = widget.task!.color;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      if (targetDate != null) {
        Navigator.pop(
            context,
            Task(
                id: widget.task == null ? 0 : widget.task!.id,
                title: _titleController.text,
                description: _descriptionController.text,
                delivery: targetDate!,
                color: currentColor,
                isCompleted: _isCompleted,
                repeat: [],
                advert: dropdownValue == null
                    ? null
                    : Duration(minutes: -dropdownValue!)));
      } else {
        setState(() => errorMessageDate = true);
      }
    }
  }

  void _selectDate(BuildContext context) async {
    setState(() => errorMessageDate = false);
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    TimeOfDay? timePicked;
    if (picked != null) {
      timePicked =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
    }
    if (timePicked != null && picked != null) {
      picked = DateTime(picked.year, picked.month, picked.day, timePicked.hour,
          timePicked.minute);
    }
    if (picked != null && picked != targetDate) {
      setState(() {
        targetDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Details Task' : 'New Task'),
        actions: [
          TextButton(
              onPressed: _saveTask,
              child: Text(widget.task != null ? 'Update' : 'Create'))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              taskLabel('Title'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                decoration: inputDecotration('Insert the title of the task'),
                validator: (value) {
                  if (value!.length > 20) {
                    return 'The length of the title must be rage from 0 to 20';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              taskLabel('Note'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    inputDecotration('Insert the description of the task'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              taskLabel('Date'),
              const SizedBox(height: 10),
              Container(
                  height: 60,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: ListTile(
                      splashColor: Colors.transparent,
                      title: Text(
                        targetDate == null
                            ? 'Please, insert a date!'
                            : _formatDate(targetDate!),
                        style: TextStyle(
                            fontSize: 15,
                            color: errorMessageDate ? Colors.red : null),
                      ),
                      onTap: () => _selectDate(context),
                      trailing: const Icon(Icons.calendar_today))),
              const SizedBox(height: 20),
              taskLabel('Status'),
              const SizedBox(height: 10),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: CheckboxListTile(
                      title: const Text('Completed'),
                      value: _isCompleted,
                      onChanged: (bool? value) =>
                          setState(() => _isCompleted = value!))),
              const SizedBox(height: 20),
              taskLabel('Remind me'),
              Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(15))),
                  child: ListTile(
                    title: DropdownButton<int>(
                      value: dropdownValue,
                      elevation: 16,
                      iconSize: 0,
                      underline: Container(height: 0),
                      onChanged: (int? value) {
                        setState(() {
                          dropdownValue = value;
                        });
                      },
                      items:
                          minutesRange.map<DropdownMenuItem<int>>((int? value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value != null
                              ? '$value minutes'
                              : 'Don\'t remind me'),
                        );
                      }).toList(),
                    ),
                    trailing: const Icon(Icons.arrow_downward),
                  )),
              const SizedBox(height: 10),
              taskLabel('Color'),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (int i = 0; i < GLOBAL.colors.length; i++) dot(i)
                ],
              )
            ],
          ),
        ),
      ));

  taskLabel(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      );
  inputDecotration(String hintText) => InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(
            borderSide: BorderSide(),
            borderRadius: BorderRadius.all(Radius.circular(15))),
      );
  _formatDate(DateTime data) {
    String hour = _formatWithZero(data.hour > 12 ? data.hour - 12 : data.hour);
    String ampm = data.hour > 11 ? 'PM' : 'AM';
    String minutes = (data.minute < 10 ? '0' : '') + data.minute.toString();
    return '$hour:$minutes $ampm ${_formatWithZero(data.day)}/${_formatWithZero(data.month)}/${data.year}';
  }

  _formatWithZero(int number) => number < 10 ? '0$number' : '$number';
  dot(int index) => Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            color: GLOBAL.colors[index],
            borderRadius: const BorderRadius.all(Radius.circular(15))),
        child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            onTap: () => setState(() => currentColor = index),
            child: currentColor == index
                ? const Icon(
                    Icons.check,
                    size: 20,
                  )
                : null),
      );
}
