class Task {
  const Task({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    DateTime? taskDate,
    required this.createdAt,
    required this.updatedAt,
  }) : taskDate = taskDate ?? createdAt;

  final int? id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime taskDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted ? 1 : 0,
    'taskDate':
        '${taskDate.year.toString().padLeft(4, '0')}-'
        '${taskDate.month.toString().padLeft(2, '0')}-'
        '${taskDate.day.toString().padLeft(2, '0')}',
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Task.fromMap(Map<String, Object?> map) => Task(
    id: map['id'] as int?,
    title: map['title'] as String? ?? '',
    description: map['description'] as String?,
    isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
    taskDate:
        DateTime.tryParse(map['taskDate'] as String? ?? '') ??
        DateTime.tryParse(map['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    createdAt:
        DateTime.tryParse(map['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt:
        DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );

  Task copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? taskDate,
    DateTime? updatedAt,
  }) => Task(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    isCompleted: isCompleted ?? this.isCompleted,
    taskDate: taskDate ?? this.taskDate,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
