class Task {
  const Task({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted ? 1 : 0,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Task.fromMap(Map<String, Object?> map) => Task(
    id: map['id'] as int?,
    title: map['title'] as String? ?? '',
    description: map['description'] as String?,
    isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
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
    DateTime? updatedAt,
  }) => Task(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
