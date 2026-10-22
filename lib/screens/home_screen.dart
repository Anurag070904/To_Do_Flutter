
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../widgets/empty_state.dart';
import '../widgets/task_card.dart';
import '../utils/app_theme.dart';
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

  List<Task> get _visibleTasks => _tasks
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

    if (changed == true) {
      await _loadTasks();
    }
  }

  Future<void> _toggle(Task task, bool value) async {
    try {
      await DatabaseHelper.instance.updateTaskCompletion(
        task.id!,
        value,
      );
      await _loadTasks();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not update completion. Please try again.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _delete(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this task?'),
        content: Text(
          '"${task.title}" will be permanently removed.',
        ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not delete the task. Please try again.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed =
        _tasks.where((task) => task.isCompleted).length;
    final pending = _tasks.length - completed;
    final progress =
        _tasks.isEmpty ? 0.0 : completed / _tasks.length;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 58,
        titleSpacing: 22,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppTheme.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Daymark',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadTasks,
            tooltip: 'Refresh tasks',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF283B68),
                      Color(0xFF536DFE),
                      Color(0xFF7487FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withValues(alpha: 0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dateLabel(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Make today count.',
                      style: TextStyle(
                        fontSize: 27,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$pending tasks to go  |  $completed completed',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DAILY PROGRESS',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: progress),
                                  duration: const Duration(milliseconds: 850),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, _) => ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: value,
                                      minHeight: 7,
                                      backgroundColor: Colors.white24,
                                      color: const Color(0xFFB8F1D2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) => FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(scale: animation, child: child),
                            ),
                            child: Text(
                              '${(progress * 100).round()}%',
                              key: ValueKey<int>((progress * 100).round()),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SegmentedButton<_TaskFilter>(
                      segments: const [
                        ButtonSegment(
                          value: _TaskFilter.all,
                          label: Text('All'),
                        ),
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
                      onSelectionChanged: (selection) {
                        setState(() {
                          _filter = selection.first;
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.10),
                        foregroundColor: Colors.white70,
                        selectedBackgroundColor: Colors.white,
                        selectedForegroundColor: AppTheme.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                ),
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
                          ? EmptyState(
                              onAdd: () =>
                                  _open(const AddTaskScreen()),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadTasks,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  4,
                                  16,
                                  96,
                                ),
                                itemCount: _visibleTasks.length,
                                itemBuilder: (context, index) {
                                  final task = _visibleTasks[index];

                                  return TweenAnimationBuilder<double>(
                                    key: ValueKey<int>(task.id!),
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: Duration(
                                      milliseconds: 350 + (index * 60).clamp(0, 300).toInt(),
                                    ),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) => Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 14 * (1 - value)),
                                        child: child,
                                      ),
                                    ),
                                    child: TaskCard(
                                      task: task,
                                      onToggle: (value) => _toggle(task, value),
                                      onEdit: () => _open(
                                        EditTaskScreen(taskId: task.id!),
                                      ),
                                      onDelete: () => _delete(task),
                                    ),
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

  String _dateLabel() {
    final now = DateTime.now();

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[now.weekday - 1].toUpperCase()}  |  '
        '${months[now.month - 1].toUpperCase()} ${now.day}';
  }
}
