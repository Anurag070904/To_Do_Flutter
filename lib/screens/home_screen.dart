import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

enum _TaskFilter { all, pending, completed }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> _tasks = [];
  bool _loading = true;
  String? _error;
  _TaskFilter _filter = _TaskFilter.all;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await DatabaseHelper.instance.getAllTasks();
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _loading = false;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Your tasks could not be loaded. Please try again.';
        });
      }
    }
  }

  List<Task> get _visibleTasks =>
      _tasks
          .where(
            (task) => switch (_filter) {
              _TaskFilter.all => true,
              _TaskFilter.pending => !task.isCompleted,
              _TaskFilter.completed => task.isCompleted,
            },
          )
          .toList();

  Future<void> _open(Widget page) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (changed == true) await _loadTasks();
  }

  Future<void> _toggle(Task task, bool value) async {
    try {
      await DatabaseHelper.instance.updateTaskCompletion(task.id!, value);
      await _loadTasks();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update completion. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _delete(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete this task?'),
            content: Text('"${task.title}" will be permanently removed.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm != true || !mounted) return;
    try {
      await DatabaseHelper.instance.deleteTask(task.id!);
      await _loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Task deleted.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete the task. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = _tasks.where((task) => task.isCompleted).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To-Do',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            onPressed: _loadTasks,
            tooltip: 'Refresh tasks',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(const AddTaskScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateTime.now().toLocal().toString().substring(0, 10),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Make today count.',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_tasks.length - completed} to do | $completed completed',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 18),
                  SegmentedButton<_TaskFilter>(
                    segments: const [
                      ButtonSegment(value: _TaskFilter.all, label: Text('All')),
                      ButtonSegment(
                        value: _TaskFilter.pending,
                        label: Text('Pending'),
                      ),
                      ButtonSegment(
                        value: _TaskFilter.completed,
                        label: Text('Completed'),
                      ),
                    ],
                    selected: {_filter},
                    onSelectionChanged:
                        (selection) =>
                            setState(() => _filter = selection.first),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: _loadTasks,
                                child: const Text('Try again'),
                              ),
                            ],
                          ),
                        ),
                      )
                      : _visibleTasks.isEmpty
                      ? const EmptyState()
                      : RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                          itemCount: _visibleTasks.length,
                          itemBuilder: (context, index) {
                            final task = _visibleTasks[index];
                            return TaskCard(
                              task: task,
                              onToggle: (value) => _toggle(task, value),
                              onEdit:
                                  () => _open(EditTaskScreen(taskId: task.id!)),
                              onDelete: () => _delete(task),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
