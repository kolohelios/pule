import 'package:flutter_test/flutter_test.dart';
import 'package:pule/models/prayer_item.dart';

void main() {
  group('PrayerItem', () {
    final baseCreatedAt = DateTime.utc(2024, 1, 15, 10, 30, 0);

    final baseItem = PrayerItem(
      id: 'item-1',
      text: 'Pray for healing',
      createdAt: baseCreatedAt,
    );

    group('default values', () {
      test('isCompleted defaults to false', () {
        expect(baseItem.isCompleted, isFalse);
      });

      test('isPaused defaults to false', () {
        expect(baseItem.isPaused, isFalse);
      });

      test('tagIds defaults to empty list', () {
        expect(baseItem.tagIds, isEmpty);
      });

      test('sortOrder defaults to 0', () {
        expect(baseItem.sortOrder, 0);
      });
    });

    group('construction with all fields', () {
      test('stores all provided values', () {
        final item = PrayerItem(
          id: 'item-2',
          text: 'Pray for peace',
          isCompleted: true,
          isPaused: false,
          tagIds: ['tag-a', 'tag-b'],
          createdAt: baseCreatedAt,
          sortOrder: 5,
        );

        expect(item.id, 'item-2');
        expect(item.text, 'Pray for peace');
        expect(item.isCompleted, isTrue);
        expect(item.isPaused, isFalse);
        expect(item.tagIds, ['tag-a', 'tag-b']);
        expect(item.createdAt, baseCreatedAt);
        expect(item.sortOrder, 5);
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct map', () {
        final json = baseItem.toJson();

        expect(json['id'], 'item-1');
        expect(json['text'], 'Pray for healing');
        expect(json['isCompleted'], false);
        expect(json['isPaused'], false);
        expect(json['tagIds'], isEmpty);
        expect(json['createdAt'], baseCreatedAt.toIso8601String());
        expect(json['sortOrder'], 0);
      });

      test('fromJson reconstructs the object', () {
        final json = {
          'id': 'item-1',
          'text': 'Pray for healing',
          'isCompleted': false,
          'isPaused': false,
          'tagIds': <String>[],
          'createdAt': baseCreatedAt.toIso8601String(),
          'sortOrder': 0,
        };

        final item = PrayerItem.fromJson(json);

        expect(item.id, 'item-1');
        expect(item.text, 'Pray for healing');
        expect(item.isCompleted, isFalse);
        expect(item.isPaused, isFalse);
        expect(item.tagIds, isEmpty);
        expect(item.createdAt, baseCreatedAt);
        expect(item.sortOrder, 0);
      });

      test('round-trip preserves all default fields', () {
        final json = baseItem.toJson();
        final restored = PrayerItem.fromJson(json);
        expect(restored, baseItem);
      });

      test('round-trip preserves all explicit fields', () {
        final item = PrayerItem(
          id: 'item-3',
          text: 'Pray for guidance',
          isCompleted: true,
          isPaused: true,
          tagIds: ['tag-1', 'tag-2', 'tag-3'],
          createdAt: baseCreatedAt,
          sortOrder: 42,
        );

        final restored = PrayerItem.fromJson(item.toJson());
        expect(restored, item);
      });

      test('fromJson applies defaults for missing optional fields', () {
        final json = {
          'id': 'item-4',
          'text': 'Pray for wisdom',
          'createdAt': baseCreatedAt.toIso8601String(),
        };

        final item = PrayerItem.fromJson(json);

        expect(item.isCompleted, isFalse);
        expect(item.isPaused, isFalse);
        expect(item.tagIds, isEmpty);
        expect(item.sortOrder, 0);
      });
    });

    group('copyWith', () {
      test('copyWith returns a new instance with updated text', () {
        final updated = baseItem.copyWith(text: 'Pray for strength');

        expect(updated.text, 'Pray for strength');
        expect(updated.id, baseItem.id);
        expect(updated.createdAt, baseItem.createdAt);
      });

      test('copyWith with isCompleted true', () {
        final completed = baseItem.copyWith(isCompleted: true);

        expect(completed.isCompleted, isTrue);
        expect(completed.id, baseItem.id);
        expect(completed.text, baseItem.text);
      });

      test('copyWith with isPaused true', () {
        final paused = baseItem.copyWith(isPaused: true);

        expect(paused.isPaused, isTrue);
        expect(paused.id, baseItem.id);
      });

      test('copyWith with updated tagIds', () {
        final tagged = baseItem.copyWith(tagIds: ['tag-x', 'tag-y']);

        expect(tagged.tagIds, ['tag-x', 'tag-y']);
        expect(tagged.id, baseItem.id);
      });

      test('copyWith with updated sortOrder', () {
        final reordered = baseItem.copyWith(sortOrder: 10);

        expect(reordered.sortOrder, 10);
        expect(reordered.id, baseItem.id);
      });

      test('copyWith without arguments returns equal object', () {
        final copy = baseItem.copyWith();
        expect(copy, baseItem);
      });

      test('copyWith does not mutate the original', () {
        final copy = baseItem.copyWith(isCompleted: true, isPaused: true);

        expect(copy.isCompleted, isTrue);
        expect(baseItem.isCompleted, isFalse);
        expect(baseItem.isPaused, isFalse);
      });
    });

    group('equality', () {
      test('two items with same fields are equal', () {
        final a = PrayerItem(
          id: 'eq-1',
          text: 'Same',
          createdAt: baseCreatedAt,
        );
        final b = PrayerItem(
          id: 'eq-1',
          text: 'Same',
          createdAt: baseCreatedAt,
        );

        expect(a, equals(b));
      });

      test('items with different ids are not equal', () {
        final a = PrayerItem(id: 'a', text: 'Same', createdAt: baseCreatedAt);
        final b = PrayerItem(id: 'b', text: 'Same', createdAt: baseCreatedAt);

        expect(a, isNot(equals(b)));
      });

      test('items with different text are not equal', () {
        final a = PrayerItem(id: 'x', text: 'Alpha', createdAt: baseCreatedAt);
        final b = PrayerItem(id: 'x', text: 'Beta', createdAt: baseCreatedAt);

        expect(a, isNot(equals(b)));
      });
    });
  });
}
