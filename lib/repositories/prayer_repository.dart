import '../models/prayer_item.dart';
import '../models/tag.dart';

abstract class PrayerRepository {
  Stream<List<PrayerItem>> watchActiveItems();
  Stream<List<PrayerItem>> watchPausedItems();
  Stream<List<Tag>> watchTags();

  Future<void> addItem(PrayerItem item);
  Future<void> updateItem(PrayerItem item);
  Future<void> deleteItem(String id);
  Future<void> pauseItem(String id);
  Future<void> resumeItem(String id);
  Future<void> resetAllCompletions();

  Future<void> addTag(Tag tag);
  Future<void> updateTag(Tag tag);
  Future<void> deleteTag(String id);
}
