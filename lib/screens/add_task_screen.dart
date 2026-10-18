import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../widgets/task_form.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New task')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Make it happen.',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Capture the next thing on your list.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 28),
          TaskForm(
            onSubmit: (title, description) async {
              final now = DateTime.now();
              try {
                await DatabaseHelper.instance.insertTask(
                  Task(
                    title: title,
                    description: description.isEmpty ? null : description,
                    createdAt: now,
                    updatedAt: now,
                  ),
                );
                if (context.mounted) Navigator.pop(context, true);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not save the task. Please try again.',
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    ),
  );
}
