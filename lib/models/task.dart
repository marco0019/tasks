class Task {
  int id;
  String title, description;
  bool isCompleted;
  DateTime delivery;
  int color;
  Duration? advert;
  List<String> repeat;
  Task(
      {required this.id,
      required this.title,
      required this.description,
      required this.delivery,
      required this.color,
      required this.repeat,
      this.isCompleted = false,
      this.advert});
  factory Task.fromJSON(Map<String, dynamic> json) => Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      delivery: DateTime.parse(json['delivery']),
      color: json['color'],
      repeat: json['repeat']
          .toString()
          .split(',').toList(),
      isCompleted: json['isCompleted'] == 1);
  bool expired() => delivery.isBefore(DateTime.now());
}
