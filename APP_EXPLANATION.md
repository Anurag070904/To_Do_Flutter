# To-Do App Explanation

## 1. What this app does
This project is a small Flutter-based to-do application for managing daily tasks. It lets a user:

- Add a new task with a title and optional description
- View all tasks in a clean list
- Mark tasks as completed or pending
- Edit an existing task
- Delete a task
- Filter tasks by All, Pending, or Completed
- Keep data saved locally on the device using SQLite

The app is designed as a local-first task manager: no backend or login is required, and data is stored directly on the device.

## 2. App overview
The app is built with Flutter and uses Material 3 styling. The main screen shows a summary header with:

- the current date
- a tagline
- counts for pending and completed tasks
- filter buttons for task categories

Below that, tasks appear as cards. Each task card contains:

- the task title
- optional description
- a checkbox to mark completion
- a menu for Edit and Delete actions

If there are no tasks, the app shows an empty-state illustration and message encouraging the user to add a task.

## 3. Core files and purpose

### lib/main.dart
This is the app entry point. It initializes the Flutter bindings and launches the app with `ToDoApp`.

- `main()` starts the app
- `ToDoApp` returns a `MaterialApp`
- the app uses a custom light theme from `lib/utils/app_theme.dart`
- the initial screen is `HomeScreen`

### lib/screens/home_screen.dart
This is the main dashboard screen.

Responsibilities:
- load tasks from the database
- keep a local list of tasks in state
- filter tasks by status
- show loading and error states
- open add/edit screens as needed
- handle toggling completion and deleting tasks

It uses `DatabaseHelper.instance` to fetch and refresh data after any change.

### lib/screens/add_task_screen.dart
This screen lets users create a new task.

It renders a `TaskForm` and, when submitted:
- builds a `Task` object
- saves it to the SQLite database
- returns to the previous screen with a success flag

### lib/screens/edit_task_screen.dart
This screen loads a selected task by `taskId` and fills the form with its existing values.

It allows the user to change:
- the title
- the description

Then it updates the record in the database.

### lib/models/task_model.dart
This file defines the `Task` model.

The model includes:
- `id`
- `title`
- `description`
- `isCompleted`
- `createdAt`
- `updatedAt`

It includes helper methods:
- `toMap()` to convert the object to database-ready data
- `fromMap()` to create a `Task` from database row data
- `copyWith()` to create a modified version of a task

### lib/database/database_helper.dart
This is the database layer for the app.

It:
- opens a local SQLite database named `to_do.db`
- creates the `tasks` table on first run
- inserts new tasks
- reads all tasks
- fetches one task by ID
- updates title, description, and completion status
- deletes tasks

The table schema is:

- `id` INTEGER PRIMARY KEY AUTOINCREMENT
- `title` TEXT NOT NULL
- `description` TEXT
- `isCompleted` INTEGER NOT NULL DEFAULT 0
- `createdAt` TEXT NOT NULL
- `updatedAt` TEXT NOT NULL

### lib/widgets/task_form.dart
This is a reusable form shared by both add and edit screens.

Features:
- title input with validation
- optional description field
- loading state while saving
- submit button with custom label

### lib/widgets/task_card.dart
This defines each task item in the list.

It shows:
- a checkbox for completion toggling
- the task title and optional description
- a popup menu with Edit and Delete actions

### lib/widgets/empty_state.dart
This is the empty state widget shown when no task exists.

It displays a checklist icon and message like:

> A clear mind starts here

### lib/utils/app_theme.dart
This file centralizes the app’s visual design.

It defines:
- large app background colors
- Material 3 theme
- custom card styling
- input field styling
- accent color theme

## 4. How the app flows
The runtime flow is straightforward:

1. `main()` launches the app.
2. `HomeScreen` is displayed.
3. `HomeScreen` calls `DatabaseHelper.instance.getAllTasks()` on startup.
4. Tasks are shown in a list, grouped by filter choice.
5. The user can tap the add button to open the add screen.
6. After saving, the screen pops back and the task list refreshes.
7. Tapping a task card or using the menu opens the edit screen.
8. Task changes are written to SQLite immediately.
9. Completing or deleting a task also refreshes the list.

## 5. Data model and state behavior
The app keeps the main task list in state inside `HomeScreen`.

State fields include:
- `_tasks` for all loaded tasks
- `_loading` to show a spinner
- `_error` to handle failed loads
- `_filter` for All/Pending/Completed

The app does not use a complex state management library such as Provider, Riverpod, or Bloc. It relies on Flutter’s built-in `setState()` for local UI updates.

## 6. Local storage approach
The app uses SQLite through the `sqflite` package.

This means:
- tasks are saved on the device
- there is no remote database or API
- the app works offline
- the database is created automatically when the app first runs

## 7. Dependencies used
The project includes these key packages:

- `flutter` for the UI framework
- `sqflite` for SQLite storage
- `path` for working with database file paths

## 8. Strengths of the app
- Simple and easy to understand
- Local-first design keeps it fast and private
- Clear task lifecycle: add, view, edit, complete, delete
- Minimal but polished Material UI
- Direct SQLite integration without backend complexity

## 9. Best way to think about the project
This app is a clean example of a lightweight Flutter CRUD (Create, Read, Update, Delete) application. It is small enough to understand quickly, but it includes all the core concepts of a mobile task manager:

- screen-based navigation
- state management with setState
- forms and validation
- local database persistence
- reusable widget structure

## 10. How to run it
From the project root:

```bash
flutter pub get
flutter run
```

This will launch the Flutter app on the connected emulator or device.

## Summary
The To-Do app is a simple but well-structured Flutter task manager that stores tasks in SQLite and supports basic task operations. Its design is intentionally focused on clarity, usability, and local persistence, making it a good example of a clean mobile app architecture for small productivity tools.
