import 'package:flutter/material.dart';

class TaskForm extends StatefulWidget {
  const TaskForm({
    super.key,
    this.initialTitle = '',
    this.initialDescription = '',
    required this.onSubmit,
    this.submitLabel = 'Save task',
  });
  final String initialTitle;
  final String initialDescription;
  final Future<void> Function(String title, String description) onSubmit;
  final String submitLabel;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initialTitle);
  late final _description = TextEditingController(
    text: widget.initialDescription,
  );
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSubmit(_title.text.trim(), _description.text.trim());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _title,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Task title',
            hintText: 'What needs to get done?',
          ),
          validator:
              (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Please enter a task title.'
                      : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _description,
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            hintText: 'Add a few details',
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon:
              _saving
                  ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.check),
          label: Text(_saving ? 'Saving…' : widget.submitLabel),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
      ],
    ),
  );
}
