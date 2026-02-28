import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pule/models/prayer_item.dart';
import 'package:pule/models/tag.dart';
import 'package:pule/providers/prayer_provider.dart';
import 'package:pule/providers/tag_provider.dart';
import 'package:pule/repositories/prayer_repository.dart';

import '../repositories/mock_prayer_repository.dart';

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(
      PrayerItem(
        id: 'fallback',
        text: 'fallback',
        createdAt: DateTime.utc(2024),
      ),
    );
    registerFallbackValue(
      const Tag(id: 'fallback', name: 'fallback', colorValue: 0xFF000000),
    );
  });

  final createdAt = DateTime.utc(2024, 6, 1);

  PrayerItem makeItem({
    required String id,
    String text = 'A prayer',
    bool isCompleted = false,
    bool isPaused = false,
    List<String> tagIds = const [],
    int sortOrder = 0,
  }) => PrayerItem(
    id: id,
    text: text,
    isCompleted: isCompleted,
    isPaused: isPaused,
    tagIds: tagIds,
    createdAt: createdAt,
    sortOrder: sortOrder,
  );

  ProviderContainer buildContainer(MockPrayerRepository mock) {
    return ProviderContainer(
      overrides: [prayerRepositoryProvider.overrideWithValue(mock)],
    );
  }

  group('activeItemsProvider', () {
    test('emits items from repository watchActiveItems', () async {
      final items = [makeItem(id: 'a'), makeItem(id: 'b')];
      final mock = buildMockRepo(activeItems: items);
      final container = buildContainer(mock);
      addTearDown(container.dispose);

      final result = await container.read(activeItemsProvider.future);
      expect(result, items);
    });

    test('emits empty list when repository has no active items', () async {
      final mock = buildMockRepo();
      final container = buildContainer(mock);
      addTearDown(container.dispose);

      final result = await container.read(activeItemsProvider.future);
      expect(result, isEmpty);
    });

    test('propagates stream errors as AsyncError', () async {
      final mock = MockPrayerRepository();
      when(
        () => mock.watchActiveItems(),
      ).thenAnswer((_) => Stream.error(Exception('db error')));
      when(() => mock.watchPausedItems()).thenAnswer((_) => Stream.value([]));
      when(() => mock.watchTags()).thenAnswer((_) => Stream.value([]));

      final container = buildContainer(mock);
      addTearDown(container.dispose);

      // Listen to the provider so the stream starts, then wait for error.
      final sub = container.listen(activeItemsProvider, (_, _) {});
      addTearDown(sub.close);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = container.read(activeItemsProvider);
      expect(state, isA<AsyncError>());
    });
  });

  group('pausedItemsProvider', () {
    test('emits paused items from repository', () async {
      final paused = [makeItem(id: 'p1', isPaused: true)];
      final mock = buildMockRepo(pausedItems: paused);
      final container = buildContainer(mock);
      addTearDown(container.dispose);

      final result = await container.read(pausedItemsProvider.future);
      expect(result, paused);
    });
  });

  group('tagsProvider', () {
    test('emits tags from repository watchTags', () async {
      const tags = [
        Tag(id: 'tag-1', name: 'Family', colorValue: 0xFF4CAF50),
        Tag(id: 'tag-2', name: 'Work', colorValue: 0xFF2196F3),
      ];
      final mock = buildMockRepo(tags: tags);
      final container = buildContainer(mock);
      addTearDown(container.dispose);

      final result = await container.read(tagsProvider.future);
      expect(result, tags);
    });

    test('emits empty list when repository has no tags', () async {
      final mock = buildMockRepo();
      final container = buildContainer(mock);
      addTearDown(container.dispose);

      final result = await container.read(tagsProvider.future);
      expect(result, isEmpty);
    });
  });

  group('selectedTagIdsProvider', () {
    test('initial state is empty set', () {
      final mock = buildMockRepo();
      final container = buildContainer(mock);
      addTearDown(container.dispose);

      expect(container.read(selectedTagIdsProvider), isEmpty);
    });

    test('state can be updated', () {
      final mock = buildMockRepo();
      final container = buildContainer(mock);
      addTearDown(container.dispose);

      container.read(selectedTagIdsProvider.notifier).state = {
        'tag-1',
        'tag-2',
      };

      expect(container.read(selectedTagIdsProvider), {'tag-1', 'tag-2'});
    });

    test('state can be cleared', () {
      final mock = buildMockRepo();
      final container = buildContainer(mock);
      addTearDown(container.dispose);

      container.read(selectedTagIdsProvider.notifier).state = {'tag-1'};
      container.read(selectedTagIdsProvider.notifier).state = {};

      expect(container.read(selectedTagIdsProvider), isEmpty);
    });
  });

  group('filteredItemsProvider', () {
    test('returns all active items when no tags are selected', () async {
      final items = [
        makeItem(id: 'i1', tagIds: ['tag-1']),
        makeItem(id: 'i2', tagIds: ['tag-2']),
        makeItem(id: 'i3'),
      ];
      final mock = buildMockRepo(activeItems: items);
      final container = buildContainer(mock);
      addTearDown(container.dispose);

      await container.read(activeItemsProvider.future);

      final filtered = container.read(filteredItemsProvider);
      expect(filtered.value, items);
    });

    test('filters items to only those matching a selected tag', () async {
      final items = [
        makeItem(id: 'i1', tagIds: ['tag-1']),
        makeItem(id: 'i2', tagIds: ['tag-2']),
        makeItem(id: 'i3', tagIds: ['tag-1', 'tag-2']),
        makeItem(id: 'i4'),
      ];
      final mock = buildMockRepo(activeItems: items);
      final container = buildContainer(mock);
      addTearDown(container.dispose);

      await container.read(activeItemsProvider.future);

      container.read(selectedTagIdsProvider.notifier).state = {'tag-1'};

      final filtered = container.read(filteredItemsProvider);
      final ids = filtered.value?.map((i) => i.id).toList();
      expect(ids, containsAll(['i1', 'i3']));
      expect(ids, isNot(contains('i2')));
      expect(ids, isNot(contains('i4')));
    });

    test('filters items matching any of multiple selected tags', () async {
      final items = [
        makeItem(id: 'i1', tagIds: ['tag-1']),
        makeItem(id: 'i2', tagIds: ['tag-2']),
        makeItem(id: 'i3', tagIds: ['tag-3']),
      ];
      final mock = buildMockRepo(activeItems: items);
      final container = buildContainer(mock);
      addTearDown(container.dispose);

      await container.read(activeItemsProvider.future);

      container.read(selectedTagIdsProvider.notifier).state = {
        'tag-1',
        'tag-2',
      };

      final filtered = container.read(filteredItemsProvider);
      final ids = filtered.value?.map((i) => i.id).toList();
      expect(ids, containsAll(['i1', 'i2']));
      expect(ids, isNot(contains('i3')));
    });

    test('returns empty list when no items match selected tag', () async {
      final items = [
        makeItem(id: 'i1', tagIds: ['tag-1']),
      ];
      final mock = buildMockRepo(activeItems: items);
      final container = buildContainer(mock);
      addTearDown(container.dispose);

      await container.read(activeItemsProvider.future);

      container.read(selectedTagIdsProvider.notifier).state = {'tag-99'};

      final filtered = container.read(filteredItemsProvider);
      expect(filtered.value, isEmpty);
    });

    test('unselecting tags restores full list', () async {
      final items = [
        makeItem(id: 'i1', tagIds: ['tag-1']),
        makeItem(id: 'i2', tagIds: ['tag-2']),
      ];
      final mock = buildMockRepo(activeItems: items);
      final container = buildContainer(mock);
      addTearDown(container.dispose);

      await container.read(activeItemsProvider.future);

      container.read(selectedTagIdsProvider.notifier).state = {'tag-1'};
      container.read(selectedTagIdsProvider.notifier).state = {};

      final filtered = container.read(filteredItemsProvider);
      expect(filtered.value, items);
    });

    test('propagates loading state from activeItemsProvider', () {
      final mock = MockPrayerRepository();
      // Use a stream that never emits so the provider stays in loading state.
      when(
        () => mock.watchActiveItems(),
      ).thenAnswer((_) => const Stream.empty());
      when(() => mock.watchPausedItems()).thenAnswer((_) => Stream.value([]));
      when(() => mock.watchTags()).thenAnswer((_) => Stream.value([]));

      final container = buildContainer(mock);
      addTearDown(container.dispose);

      final state = container.read(filteredItemsProvider);
      expect(state, isA<AsyncLoading>());
    });
  });

  group('prayerRepositoryProvider', () {
    test('returns the overridden repository instance', () {
      final mock = buildMockRepo();
      final container = buildContainer(mock);
      addTearDown(container.dispose);

      final repo = container.read(prayerRepositoryProvider);
      expect(repo, isA<PrayerRepository>());
      expect(repo, same(mock));
    });
  });
}
