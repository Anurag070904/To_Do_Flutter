import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> {
  DateTime _selectedDate = _dateOnly(DateTime.now());
  List<Task> _tasks = [];
  bool _loading = true;
  String? _error;

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final date = _selectedDate;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tasks = await DatabaseHelper.instance.getTasksForDate(date);
      if (!mounted || !_sameDay(date, _selectedDate)) return;
      setState(() {
        _tasks = tasks;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || !_sameDay(date, _selectedDate)) return;
      setState(() {
        _loading = false;
        _error = 'Your tasks could not be loaded. Please try again.';
      });
    }
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  Future<void> _selectDate(DateTime date) async {
    setState(() => _selectedDate = _dateOnly(date));
    await _loadTasks();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) await _selectDate(date);
  }

  Future<void> _open(Widget page) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (changed == true && mounted) await _loadTasks();
  }

  Future<void> _toggle(Task task, bool value) async {
    try {
      await DatabaseHelper.instance.updateTaskCompletion(task.id!, value);
      await _loadTasks();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update completion. Please try again.'),
        ),
      );
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
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete the task. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = _tasks.where((task) => task.isCompleted).length;
    final progress = _tasks.isEmpty ? 0.0 : completed / _tasks.length;
    final dateLabel = MaterialLocalizations.of(
      context,
    ).formatMediumDate(_selectedDate);
    final isToday = _sameDay(_selectedDate, DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Daily checklist')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(AddTaskScreen(taskDate: _selectedDate)),
        icon: const Icon(Icons.add),
        label: const Text('Add to this day'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Previous day',
                            onPressed:
                                () => _selectDate(
                                  _selectedDate.subtract(
                                    const Duration(days: 1),
                                  ),
                                ),
                            icon: const Icon(Icons.chevron_left_rounded),
                          ),
                          Expanded(
                            child: TextButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_month_rounded),
                              label: Text(
                                isToday ? 'Today · $dateLabel' : dateLabel,
                                style: const TextStyle(
                                  color: AppTheme.ink,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Next day',
                            onPressed:
                                () => _selectDate(
                                  _selectedDate.add(const Duration(days: 1)),
                                ),
                            icon: const Icon(Icons.chevron_right_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: AppTheme.accent.withValues(
                                  alpha: 0.12,
                                ),
                                color: const Color(0xFF54B990),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$completed / ${_tasks.length} done',
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                      : _tasks.isEmpty
                      ? EmptyState(
                        onAdd:
                            () => _open(AddTaskScreen(taskDate: _selectedDate)),
                      )
                      : RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
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
