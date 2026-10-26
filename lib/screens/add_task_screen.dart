import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../widgets/task_form.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key, this.taskDate});

  final DateTime? taskDate;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New task')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF283B68), Color(0xFF536DFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0x33FFFFFF),
                  child: Icon(Icons.auto_awesome_rounded, color: Colors.white),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A fresh start',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'One step at a time.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: TaskForm(
                onSubmit: (title, description) async {
                  final now = DateTime.now();
                  try {
                    await DatabaseHelper.instance.insertTask(
                      Task(
                        title: title,
                        description: description.isEmpty ? null : description,
                        taskDate: taskDate ?? now,
                        createdAt: now,
                        updatedAt: now,
                      ),
                    );
                    if (context.mounted) Navigator.pop(context, true);
                  } catch (error, stackTrace) {
                    debugPrint('Could not save task: $error');
                    debugPrintStack(stackTrace: stackTrace);
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
            ),
          ),
        ],
      ),
    ),
  );
}
