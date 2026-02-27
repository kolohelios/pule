import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/prayer_item.dart';
import '../repositories/prayer_repository.dart';
import '../repositories/repository_factory.dart';

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return createPrayerRepository();
});

final activeItemsProvider = StreamProvider<List<PrayerItem>>((ref) {
  final repo = ref.watch(prayerRepositoryProvider);
  return repo.watchActiveItems();
});

final pausedItemsProvider = StreamProvider<List<PrayerItem>>((ref) {
  final repo = ref.watch(prayerRepositoryProvider);
  return repo.watchPausedItems();
});

final selectedTagIdsProvider =
    StateProvider<Set<String>>((ref) => {});

final filteredItemsProvider = Provider<AsyncValue<List<PrayerItem>>>((ref) {
  final itemsAsync = ref.watch(activeItemsProvider);
  final selectedTagIds = ref.watch(selectedTagIdsProvider);

  if (selectedTagIds.isEmpty) {
    return itemsAsync;
  }

  return itemsAsync.whenData((items) => items
      .where(
          (item) => item.tagIds.any((tagId) => selectedTagIds.contains(tagId)))
      .toList());
});
