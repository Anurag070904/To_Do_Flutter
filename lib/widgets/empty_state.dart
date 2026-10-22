import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.onAdd});
  final VoidCallback? onAdd;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(alignment: Alignment.center, children: [
            Container(width: 100, height: 100, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .45), shape: BoxShape.circle)),
            Container(width: 76, height: 76, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(26)), child: Icon(Icons.checklist_rounded, size: 38, color: Theme.of(context).colorScheme.primary)),
            Positioned(right: 2, top: 2, child: Icon(Icons.auto_awesome_rounded, size: 22, color: Theme.of(context).colorScheme.tertiary)),
          ]),
          const SizedBox(height: 20),
          const Text(
            'A clear mind starts here',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          if (onAdd != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_rounded), label: const Text('Create a task')),
          ],
          const SizedBox(height: 8),
          const Text(
            'Add your first task and make space for what matters.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, height: 1.4),
          ),
        ],
      ),
    ),
  );
}
