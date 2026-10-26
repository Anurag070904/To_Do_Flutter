import 'dart:io';

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

  test('returns tasks scheduled for the selected day only', () async {
    final selectedDay = DateTime(2026, 1, 2);
    await database.insertTask(
      Task(
        title: 'Today',
        taskDate: selectedDay,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await database.insertTask(
      Task(
        title: 'Tomorrow',
        taskDate: selectedDay.add(const Duration(days: 1)),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final tasks = await database.getTasksForDate(DateTime(2026, 1, 2, 18));

    expect(tasks.map((task) => task.title), ['Today']);
    expect(tasks.single.taskDate, selectedDay);
  });

  test(
    'upgrades an existing database and allows new tasks to be saved',
    () async {
      final path =
          '${Directory.systemTemp.path}${Platform.pathSeparator}'
          'to_do_migration_${DateTime.now().microsecondsSinceEpoch}.db';
      final oldDatabase = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            isCompleted INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )''');
            await db.insert('tasks', {
              'title': 'Existing task',
              'description': null,
              'isCompleted': 0,
              'createdAt': now.toIso8601String(),
              'updatedAt': now.toIso8601String(),
            });
          },
        ),
      );
      await oldDatabase.close();

      final upgradedDatabase = DatabaseHelper.forTesting(
        factory: databaseFactoryFfi,
        databasePath: path,
      );
      try {
        final existing = await upgradedDatabase.getTaskById(1);
        expect(existing?.taskDate, DateTime(2026, 1, 1));

        final id = await upgradedDatabase.insertTask(
          Task(title: 'New task', createdAt: now, updatedAt: now),
        );
        expect(id, greaterThan(1));
      } finally {
        await upgradedDatabase.close();
        await File(path).delete();
      }
    },
  );
}
