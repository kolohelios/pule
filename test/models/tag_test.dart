import 'package:flutter_test/flutter_test.dart';
import 'package:pule/models/tag.dart';

void main() {
  group('Tag', () {
    const baseTag = Tag(id: 'tag-1', name: 'Family', colorValue: 0xFF4CAF50);

    group('construction', () {
      test('stores all provided values', () {
        expect(baseTag.id, 'tag-1');
        expect(baseTag.name, 'Family');
        expect(baseTag.colorValue, 0xFF4CAF50);
      });

      test('different color values are stored correctly', () {
        const tag = Tag(id: 't', name: 'Work', colorValue: 0xFF2196F3);
        expect(tag.colorValue, 0xFF2196F3);
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct map', () {
        final json = baseTag.toJson();

        expect(json['id'], 'tag-1');
        expect(json['name'], 'Family');
        expect(json['colorValue'], 0xFF4CAF50);
      });

      test('fromJson reconstructs the object', () {
        final json = {
          'id': 'tag-1',
          'name': 'Family',
          'colorValue': 0xFF4CAF50,
        };

        final tag = Tag.fromJson(json);

        expect(tag.id, 'tag-1');
        expect(tag.name, 'Family');
        expect(tag.colorValue, 0xFF4CAF50);
      });

      test('round-trip preserves all fields', () {
        final json = baseTag.toJson();
        final restored = Tag.fromJson(json);
        expect(restored, baseTag);
      });

      test('round-trip with a different tag', () {
        const tag = Tag(id: 'tag-99', name: 'Health', colorValue: 0xFFE91E63);
        final restored = Tag.fromJson(tag.toJson());
        expect(restored, tag);
      });

      test('colorValue survives JSON round-trip as integer', () {
        const tag = Tag(id: 't', name: 'Test', colorValue: 0xFF000000);
        final json = tag.toJson();

        expect(json['colorValue'], isA<int>());
        expect(Tag.fromJson(json).colorValue, 0xFF000000);
      });
    });

    group('copyWith', () {
      test('copyWith returns new instance with updated name', () {
        final updated = baseTag.copyWith(name: 'Friends');

        expect(updated.name, 'Friends');
        expect(updated.id, baseTag.id);
        expect(updated.colorValue, baseTag.colorValue);
      });

      test('copyWith returns new instance with updated colorValue', () {
        final updated = baseTag.copyWith(colorValue: 0xFFFF5722);

        expect(updated.colorValue, 0xFFFF5722);
        expect(updated.id, baseTag.id);
        expect(updated.name, baseTag.name);
      });

      test('copyWith returns new instance with updated id', () {
        final updated = baseTag.copyWith(id: 'tag-new');

        expect(updated.id, 'tag-new');
        expect(updated.name, baseTag.name);
        expect(updated.colorValue, baseTag.colorValue);
      });

      test('copyWith without arguments returns equal object', () {
        final copy = baseTag.copyWith();
        expect(copy, baseTag);
      });

      test('copyWith does not mutate the original', () {
        final copy = baseTag.copyWith(name: 'Changed', colorValue: 0xFF000000);

        expect(copy.name, 'Changed');
        expect(baseTag.name, 'Family');
        expect(baseTag.colorValue, 0xFF4CAF50);
      });
    });

    group('equality', () {
      test('two tags with same fields are equal', () {
        const a = Tag(id: 'eq-1', name: 'Same', colorValue: 0xFFABCDEF);
        const b = Tag(id: 'eq-1', name: 'Same', colorValue: 0xFFABCDEF);

        expect(a, equals(b));
      });

      test('tags with different ids are not equal', () {
        const a = Tag(id: 'a', name: 'Same', colorValue: 0xFF000000);
        const b = Tag(id: 'b', name: 'Same', colorValue: 0xFF000000);

        expect(a, isNot(equals(b)));
      });

      test('tags with different names are not equal', () {
        const a = Tag(id: 'x', name: 'Alpha', colorValue: 0xFF000000);
        const b = Tag(id: 'x', name: 'Beta', colorValue: 0xFF000000);

        expect(a, isNot(equals(b)));
      });

      test('tags with different colorValues are not equal', () {
        const a = Tag(id: 'x', name: 'Same', colorValue: 0xFF111111);
        const b = Tag(id: 'x', name: 'Same', colorValue: 0xFF222222);

        expect(a, isNot(equals(b)));
      });
    });
  });
}
