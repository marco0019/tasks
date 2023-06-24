import 'package:flutter/material.dart';

class EmptyTaskPage extends StatelessWidget {
  final String title;
  final String subtitle;
  const EmptyTaskPage({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.calendar_month,
          size: 200,
          color: Colors.grey,
        ),
        Text(title,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        Text(subtitle),
        const SizedBox(height: 100)
      ],
    );
  }
}
