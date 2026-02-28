import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/prayer_item.dart';
import '../providers/prayer_provider.dart';
import '../widgets/tag_picker.dart';

class AddPrayerScreen extends ConsumerStatefulWidget {
  const AddPrayerScreen({super.key});

  @override
  ConsumerState<AddPrayerScreen> createState() => _AddPrayerScreenState();
}

class _AddPrayerScreenState extends ConsumerState<AddPrayerScreen> {
  final _controller = TextEditingController();
  Set<String> _selectedTagIds = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Prayer'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Enter your prayer...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text('Tags', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TagPicker(
              selectedTagIds: _selectedTagIds,
              onChanged: (ids) {
                setState(() => _selectedTagIds = ids);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final repo = ref.read(prayerRepositoryProvider);
    final items = ref.read(activeItemsProvider).valueOrNull ?? [];

    final item = PrayerItem(
      id: const Uuid().v4(),
      text: text,
      createdAt: DateTime.now(),
      tagIds: _selectedTagIds.toList(),
      sortOrder: items.length,
    );

    repo.addItem(item);
    Navigator.pop(context);
  }
}
