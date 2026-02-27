import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tag.dart';
import 'prayer_provider.dart';

final tagsProvider = StreamProvider<List<Tag>>((ref) {
  final repo = ref.watch(prayerRepositoryProvider);
  return repo.watchTags();
});
