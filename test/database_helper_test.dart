import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:to_do/database/database_helper.dart';
import 'package:to_do/models/task_model.dart';

void main() {
  late DatabaseHelper database;
  final now = DateTime.utc(2026, 1, 1);

  setUpAll(() => sqfliteFfiInit());
  setUp(
    () =>
        database = DatabaseHelper.forTesting(
          factory: databaseFactoryFfi,
          databasePath: inMemoryDatabasePath,
        ),
  );
  tearDown(() => database.close());

  test('supports task create, read, update, completion, and delete', () async {
    final id = await database.insertTask(
      Task(
        title: 'Draft',
        description: 'First pass',
        createdAt: now,
        updatedAt: now,
      ),
    );
    expect(id, greaterThan(0));

    final found = await database.getTaskById(id);
    expect(found?.title, 'Draft');
    expect((await database.getAllTasks()).length, 1);

    await database.updateTask(
      Task(
        id: id,
        title: 'Draft report',
        description: 'Revised',
        createdAt: now,
        updatedAt: now.add(const Duration(hours: 1)),
      ),
    );
    expect((await database.getTaskById(id))?.title, 'Draft report');

    await database.updateTaskCompletion(id, true);
    expect((await database.getTaskById(id))?.isCompleted, isTrue);

    await database.deleteTask(id);
    expect(await database.getTaskById(id), isNull);
    expect(await database.getAllTasks(), isEmpty);
  });
}
