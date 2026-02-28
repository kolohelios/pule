import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/prayer_provider.dart';
import '../widgets/prayer_tile.dart';

class PausedScreen extends ConsumerWidget {
  const PausedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pausedAsync = ref.watch(pausedItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paused Prayers')),
      body: pausedAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Text(
                'No paused prayers',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return PrayerTile(
                item: items[index],
                showPauseAction: false,
                showResumeAction: true,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
