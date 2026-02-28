import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/tag.dart';
import '../providers/prayer_provider.dart';
import '../providers/tag_provider.dart';

const _presetColors = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.orange,
  Colors.brown,
];

class TagManagementScreen extends ConsumerWidget {
  const TagManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Tags')),
      body: tagsAsync.when(
        data: (tags) {
          if (tags.isEmpty) {
            return Center(
              child: Text(
                'No tags yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(tag.colorValue),
                  radius: 14,
                ),
                title: Text(tag.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditTagDialog(context, ref, tag),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDeleteTag(context, ref, tag),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTagDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTagDialog(BuildContext context, WidgetRef ref) {
    _showTagDialog(
      context: context,
      title: 'Add Tag',
      onSave: (name, colorValue) {
        final repo = ref.read(prayerRepositoryProvider);
        final tag = Tag(
          id: const Uuid().v4(),
          name: name,
          colorValue: colorValue,
        );
        repo.addTag(tag);
      },
    );
  }

  void _showEditTagDialog(BuildContext context, WidgetRef ref, Tag tag) {
    _showTagDialog(
      context: context,
      title: 'Edit Tag',
      initialName: tag.name,
      initialColor: tag.colorValue,
      onSave: (name, colorValue) {
        final repo = ref.read(prayerRepositoryProvider);
        repo.updateTag(tag.copyWith(name: name, colorValue: colorValue));
      },
    );
  }

  void _confirmDeleteTag(BuildContext context, WidgetRef ref, Tag tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete tag?'),
        content: Text(
          'Delete "${tag.name}"? It will be removed from all prayers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(prayerRepositoryProvider).deleteTag(tag.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTagDialog({
    required BuildContext context,
    required String title,
    String? initialName,
    int? initialColor,
    required void Function(String name, int colorValue) onSave,
  }) {
    final controller = TextEditingController(text: initialName);
    var selectedColor = initialColor ?? _presetColors.first.toARGB32();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Tag name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetColors.map((color) {
                  final colorInt = color.toARGB32();
                  final isSelected = selectedColor == colorInt;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = colorInt),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  onSave(name, selectedColor);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
