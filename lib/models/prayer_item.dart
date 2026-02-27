import 'package:freezed_annotation/freezed_annotation.dart';

part 'prayer_item.freezed.dart';
part 'prayer_item.g.dart';

@freezed
class PrayerItem with _$PrayerItem {
  const factory PrayerItem({
    required String id,
    required String text,
    @Default(false) bool isCompleted,
    @Default(false) bool isPaused,
    @Default([]) List<String> tagIds,
    required DateTime createdAt,
    @Default(0) int sortOrder,
  }) = _PrayerItem;

  factory PrayerItem.fromJson(Map<String, dynamic> json) =>
      _$PrayerItemFromJson(json);
}
