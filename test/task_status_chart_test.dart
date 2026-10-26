import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do/utils/app_theme.dart';
import 'package:to_do/widgets/task_status_chart.dart';

void main() {
  testWidgets('shows the total, completed, and pending task counts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: TaskStatusChart(completed: 3, pending: 2)),
      ),
    );

    expect(find.text('Task overview'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('renders a zero-task chart without errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TaskStatusChart(completed: 0, pending: 0)),
      ),
    );

    expect(find.text('0'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
