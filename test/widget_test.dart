import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pule/models/prayer_item.dart';
import 'package:pule/models/tag.dart';
import 'package:pule/providers/prayer_provider.dart';
import 'package:pule/screens/home_screen.dart';

import 'repositories/mock_prayer_repository.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _createdAt = DateTime.utc(2024, 6, 1);

PrayerItem _makeItem({
  required String id,
  String text = 'A prayer',
  bool isCompleted = false,
  List<String> tagIds = const [],
  int sortOrder = 0,
}) => PrayerItem(
  id: id,
  text: text,
  isCompleted: isCompleted,
  tagIds: tagIds,
  createdAt: _createdAt,
  sortOrder: sortOrder,
);

/// Wraps [HomeScreen] in a [MaterialApp] + [ProviderScope] with the given mock
/// repository overriding [prayerRepositoryProvider].
Widget _buildHomeScreen(MockPrayerRepository mock) {
  return ProviderScope(
    overrides: [prayerRepositoryProvider.overrideWithValue(mock)],
    child: const MaterialApp(home: HomeScreen()),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(
      PrayerItem(id: 'fb', text: 'fb', createdAt: DateTime.utc(2024)),
    );
    registerFallbackValue(
      const Tag(id: 'fb', name: 'fb', colorValue: 0xFF000000),
    );
  });

  group('HomeScreen', () {
    group('empty state', () {
      testWidgets('shows empty-state message when no prayers exist', (
        tester,
      ) async {
        final mock = buildMockRepo();
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump(); // let streams deliver

        expect(find.text('No prayers yet'), findsOneWidget);
        expect(find.text('Tap + to add your first prayer'), findsOneWidget);
      });

      testWidgets('shows empty-state icon when no prayers exist', (
        tester,
      ) async {
        final mock = buildMockRepo();
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
      });
    });

    group('prayer list', () {
      testWidgets('renders a prayer item in the list', (tester) async {
        final items = [_makeItem(id: 'i1', text: 'Pray for healing')];
        final mock = buildMockRepo(activeItems: items);
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        expect(find.text('Pray for healing'), findsOneWidget);
        expect(find.text('No prayers yet'), findsNothing);
      });

      testWidgets('renders multiple prayer items', (tester) async {
        final items = [
          _makeItem(id: 'i1', text: 'Pray for peace'),
          _makeItem(id: 'i2', text: 'Pray for strength'),
          _makeItem(id: 'i3', text: 'Pray for guidance'),
        ];
        final mock = buildMockRepo(activeItems: items);
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        expect(find.text('Pray for peace'), findsOneWidget);
        expect(find.text('Pray for strength'), findsOneWidget);
        expect(find.text('Pray for guidance'), findsOneWidget);
      });

      testWidgets('shows loading indicator while stream is pending', (
        tester,
      ) async {
        final mock = MockPrayerRepository();
        // Use a StreamController that never emits so the provider stays loading.
        when(
          () => mock.watchActiveItems(),
        ).thenAnswer((_) => const Stream.empty());
        when(() => mock.watchPausedItems()).thenAnswer((_) => Stream.value([]));
        when(() => mock.watchTags()).thenAnswer((_) => Stream.value([]));

        await tester.pumpWidget(_buildHomeScreen(mock));
        // Do NOT pump() extra ticks — stream hasn't emitted yet.

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('shows error text when stream emits an error', (
        tester,
      ) async {
        final mock = MockPrayerRepository();
        when(
          () => mock.watchActiveItems(),
        ).thenAnswer((_) => Stream.error('something went wrong'));
        when(() => mock.watchPausedItems()).thenAnswer((_) => Stream.value([]));
        when(() => mock.watchTags()).thenAnswer((_) => Stream.value([]));

        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        expect(find.textContaining('Error'), findsOneWidget);
      });
    });

    group('app bar', () {
      testWidgets('shows app title "Pule"', (tester) async {
        final mock = buildMockRepo();
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        expect(find.text('Pule'), findsOneWidget);
      });

      testWidgets('has a popup menu button', (tester) async {
        final mock = buildMockRepo();
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      });

      testWidgets('popup menu contains expected entries', (tester) async {
        final mock = buildMockRepo();
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();

        expect(find.text('Reset all'), findsOneWidget);
        expect(find.text('Share list'), findsOneWidget);
        expect(find.text('Paused items'), findsOneWidget);
        expect(find.text('Manage tags'), findsOneWidget);
      });
    });

    group('floating action button', () {
      testWidgets('FAB is present', (tester) async {
        final mock = buildMockRepo();
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });
    });

    group('tag filter chips', () {
      testWidgets('tag chips are not shown when there are no tags', (
        tester,
      ) async {
        final mock = buildMockRepo();
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        expect(find.byType(FilterChip), findsNothing);
      });

      testWidgets('tag chips appear when tags exist', (tester) async {
        const tags = [
          Tag(id: 'tag-1', name: 'Family', colorValue: 0xFF4CAF50),
          Tag(id: 'tag-2', name: 'Work', colorValue: 0xFF2196F3),
        ];
        final mock = buildMockRepo(tags: tags);
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        expect(find.text('Family'), findsOneWidget);
        expect(find.text('Work'), findsOneWidget);
      });

      testWidgets('tapping a tag chip updates selectedTagIdsProvider', (
        tester,
      ) async {
        const tags = [Tag(id: 'tag-1', name: 'Family', colorValue: 0xFF4CAF50)];
        final items = [
          _makeItem(id: 'i1', text: 'Pray for family', tagIds: ['tag-1']),
          _makeItem(id: 'i2', text: 'Pray for work'),
        ];
        final mock = buildMockRepo(activeItems: items, tags: tags);
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        // Before filtering: both items visible
        expect(find.text('Pray for family'), findsOneWidget);
        expect(find.text('Pray for work'), findsOneWidget);

        // Tap the FilterChip (not the small tag Chip on the prayer item)
        await tester.tap(find.byType(FilterChip));
        await tester.pump();

        // After filtering: only tagged item visible
        expect(find.text('Pray for family'), findsOneWidget);
        expect(find.text('Pray for work'), findsNothing);
      });

      testWidgets('tapping an active tag chip deselects it', (tester) async {
        const tags = [Tag(id: 'tag-1', name: 'Family', colorValue: 0xFF4CAF50)];
        final items = [
          _makeItem(id: 'i1', text: 'Pray for family', tagIds: ['tag-1']),
          _makeItem(id: 'i2', text: 'Pray for work'),
        ];
        final mock = buildMockRepo(activeItems: items, tags: tags);
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        // Select tag via FilterChip
        await tester.tap(find.byType(FilterChip));
        await tester.pump();
        expect(find.text('Pray for work'), findsNothing);

        // Deselect tag via FilterChip
        await tester.tap(find.byType(FilterChip));
        await tester.pump();
        expect(find.text('Pray for work'), findsOneWidget);
      });
    });

    group('reset confirmation dialog', () {
      testWidgets('opens reset confirmation dialog from menu', (tester) async {
        final mock = buildMockRepo();
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Reset all'));
        await tester.pumpAndSettle();

        expect(find.text('Reset all?'), findsOneWidget);
        expect(
          find.text(
            'This will uncheck all completed prayers for a fresh start.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('cancelling reset dialog does not call resetAllCompletions', (
        tester,
      ) async {
        final mock = buildMockRepo();
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Reset all'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        verifyNever(() => mock.resetAllCompletions());
      });

      testWidgets('confirming reset calls resetAllCompletions', (tester) async {
        final mock = buildMockRepo();
        await tester.pumpWidget(_buildHomeScreen(mock));
        await tester.pump();

        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Reset all'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Reset'));
        await tester.pumpAndSettle();

        verify(() => mock.resetAllCompletions()).called(1);
      });
    });
  });
}
