import 'dart:io';

import 'firebase_prayer_repository.dart';
import 'icloud_prayer_repository.dart';
import 'prayer_repository.dart';

PrayerRepository createPrayerRepository() {
  if (Platform.isIOS) {
    return ICloudPrayerRepository();
  }
  return FirebasePrayerRepository();
}
