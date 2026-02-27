import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/prayer_provider.dart';
import '../providers/tag_provider.dart';
import '../services/share_service.dart';
import '../widgets/prayer_tile.dart';
import '../widgets/tag_chip.dart';
import 'add_prayer_screen.dart';
import 'paused_screen.dart';
import 'tag_management_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredItemsProvider);
    final tagsAsync = ref.watch(tagsProvider);
    final selectedTagIds = ref.watch(selectedTagIdsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pule'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) =>
                _handleMenuAction(context, ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Reset all'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share list'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'paused',
                child: ListTile(
                  leading: Icon(Icons.pause_circle_outline),
                  title: Text('Paused items'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'tags',
                child: ListTile(
                  leading: Icon(Icons.label_outline),
                  title: Text('Manage tags'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Tag filter chips
          tagsAsync.when(
            data: (tags) {
              if (tags.isEmpty) return const SizedBox.shrink();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: tags.map((tag) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TagChip(
                        tag: tag,
                        selected: selectedTagIds.contains(tag.id),
                        onTap: () {
                          final current =
                              ref.read(selectedTagIdsProvider);
                          final newSet = Set<String>.from(current);
                          if (newSet.contains(tag.id)) {
                            newSet.remove(tag.id);
                          } else {
                            newSet.add(tag.id);
                          }
                          ref.read(selectedTagIdsProvider.notifier).state =
                              newSet;
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Prayer items list
          Expanded(
            child: filteredAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_outline,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(100)),
                        const SizedBox(height: 16),
                        Text(
                          'No prayers yet',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(150),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first prayer',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(100),
                              ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return PrayerTile(item: items[index]);
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPrayerScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _handleMenuAction(
      BuildContext context, WidgetRef ref, String action) {
    final repo = ref.read(prayerRepositoryProvider);
    switch (action) {
      case 'reset':
        _confirmReset(context, repo);
      case 'share':
        final items = ref.read(activeItemsProvider).valueOrNull ?? [];
        final tags = ref.read(tagsProvider).valueOrNull ?? [];
        ShareService.shareList(items, tags);
      case 'paused':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PausedScreen(),
          ),
        );
      case 'tags':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TagManagementScreen(),
          ),
        );
    }
  }

  void _confirmReset(BuildContext context, dynamic repo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all?'),
        content: const Text(
            'This will uncheck all completed prayers for a fresh start.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              repo.resetAllCompletions();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
