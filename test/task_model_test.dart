import 'package:flutter_test/flutter_test.dart';
import 'package:to_do/models/task_model.dart';

void main() {
  test('serializes and restores task values', () {
    final created = DateTime.utc(2026, 1, 2, 3, 4);
    final updated = DateTime.utc(2026, 1, 3, 4, 5);
    final task = Task(
      id: 7,
      title: 'Review notes',
      description: 'Chapter two',
      isCompleted: true,
      createdAt: created,
      updatedAt: updated,
    );
    final restored = Task.fromMap(task.toMap());

    expect(restored.id, 7);
    expect(restored.title, 'Review notes');
    expect(restored.description, 'Chapter two');
    expect(restored.isCompleted, isTrue);
    expect(restored.createdAt, created);
    expect(restored.updatedAt, updated);
  });

  test('omits an unset ID for auto increment', () {
    final task = Task(
      title: 'New',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    expect(task.toMap().containsKey('id'), isFalse);
    expect(task.toMap()['isCompleted'], 0);
  });
}
