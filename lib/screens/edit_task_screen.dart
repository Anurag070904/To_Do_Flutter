import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../widgets/task_form.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({super.key, required this.taskId});
  final int taskId;
  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final Future<Task?> _task = DatabaseHelper.instance.getTaskById(
    widget.taskId,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit task')),
    body: FutureBuilder<Task?>(
      future: _task,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final task = snapshot.data;
        if (snapshot.hasError || task == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 42),
                  const SizedBox(height: 12),
                  const Text('This task could not be found.'),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Refine your plan.',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            TaskForm(
              initialTitle: task.title,
              initialDescription: task.description ?? '',
              submitLabel: 'Save changes',
              onSubmit: (title, description) async {
                try {
                  await DatabaseHelper.instance.updateTask(
                    Task(
                      id: task.id,
                      title: title,
                      description: description.isEmpty ? null : description,
                      isCompleted: task.isCompleted,
                      createdAt: task.createdAt,
                      updatedAt: DateTime.now(),
                    ),
                  );
                  if (context.mounted) Navigator.pop(context, true);
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not update the task. Please try again.',
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    ),
  );
}
