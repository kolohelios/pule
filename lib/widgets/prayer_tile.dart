import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/prayer_item.dart';
import '../providers/prayer_provider.dart';
import '../providers/tag_provider.dart';

class PrayerTile extends ConsumerWidget {
  const PrayerTile({
    super.key,
    required this.item,
    this.showPauseAction = true,
    this.showResumeAction = false,
  });

  final PrayerItem item;
  final bool showPauseAction;
  final bool showResumeAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(prayerRepositoryProvider);
    final tagsAsync = ref.watch(tagsProvider);
    final allTags = tagsAsync.valueOrNull ?? [];
    final itemTags =
        allTags.where((tag) => item.tagIds.contains(tag.id)).toList();

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      confirmDismiss: (_) async {
        if (showPauseAction) {
          return await _showDeleteOrPauseDialog(context);
        }
        return true;
      },
      onDismissed: (_) => repo.deleteItem(item.id),
      child: CheckboxListTile(
        value: item.isCompleted,
        onChanged: (value) {
          repo.updateItem(item.copyWith(isCompleted: value ?? false));
        },
        title: Text(
          item.text,
          style: item.isCompleted
              ? TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color
                      ?.withAlpha(128),
                )
              : null,
        ),
        subtitle: itemTags.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 4,
                  children: itemTags
                      .map((tag) => Chip(
                            label: Text(tag.name,
                                style: const TextStyle(fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            backgroundColor:
                                Color(tag.colorValue).withAlpha(60),
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 6),
                          ))
                      .toList(),
                ),
              )
            : null,
        secondary: showResumeAction
            ? IconButton(
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Resume',
                onPressed: () => repo.resumeItem(item.id),
              )
            : showPauseAction
                ? IconButton(
                    icon: const Icon(Icons.pause),
                    tooltip: 'Pause',
                    onPressed: () => repo.pauseItem(item.id),
                  )
                : null,
      ),
    );
  }

  Future<bool?> _showDeleteOrPauseDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove item'),
        content: const Text('Would you like to pause or delete this prayer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final repo =
                  ProviderScope.containerOf(context).read(prayerRepositoryProvider);
              repo.pauseItem(item.id);
              Navigator.pop(context, false);
            },
            child: const Text('Pause'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
