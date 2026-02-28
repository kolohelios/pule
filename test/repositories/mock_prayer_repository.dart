import 'package:mocktail/mocktail.dart';
import 'package:pule/models/prayer_item.dart';
import 'package:pule/models/tag.dart';
import 'package:pule/repositories/prayer_repository.dart';

class MockPrayerRepository extends Mock implements PrayerRepository {}

/// Returns a [MockPrayerRepository] pre-configured with sensible stream stubs.
///
/// All watch* methods emit an empty list by default. Individual tests can
/// override specific stubs with `when(...).thenAnswer(...)` after calling this.
MockPrayerRepository buildMockRepo({
  List<PrayerItem> activeItems = const [],
  List<PrayerItem> pausedItems = const [],
  List<Tag> tags = const [],
}) {
  final mock = MockPrayerRepository();

  when(
    () => mock.watchActiveItems(),
  ).thenAnswer((_) => Stream.value(activeItems));
  when(
    () => mock.watchPausedItems(),
  ).thenAnswer((_) => Stream.value(pausedItems));
  when(() => mock.watchTags()).thenAnswer((_) => Stream.value(tags));

  when(() => mock.addItem(any())).thenAnswer((_) async {});
  when(() => mock.updateItem(any())).thenAnswer((_) async {});
  when(() => mock.deleteItem(any())).thenAnswer((_) async {});
  when(() => mock.pauseItem(any())).thenAnswer((_) async {});
  when(() => mock.resumeItem(any())).thenAnswer((_) async {});
  when(() => mock.resetAllCompletions()).thenAnswer((_) async {});
  when(() => mock.addTag(any())).thenAnswer((_) async {});
  when(() => mock.updateTag(any())).thenAnswer((_) async {});
  when(() => mock.deleteTag(any())).thenAnswer((_) async {});

  return mock;
}
