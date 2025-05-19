import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onToggleStatus;

  const TaskTile({super.key, required this.task, this.onToggleStatus});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          task.title,
          style: task.status == 'done'
              ? const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)
              : const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('Para: ${task.dueDate.toLocal().toIso8601String().split("T").first}'),
        trailing: IconButton(
          icon: Icon(
            task.status == 'done' ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task.status == 'done' ? Colors.green : Colors.grey,
          ),
          onPressed: onToggleStatus,
        ),
      ),
    );
  }
}