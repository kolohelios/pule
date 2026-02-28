import 'package:share_plus/share_plus.dart';

import '../models/prayer_item.dart';
import '../models/tag.dart';

class ShareService {
  static Future<void> shareList(
      List<PrayerItem> items, List<Tag> tags) async {
    if (items.isEmpty) return;

    final tagMap = {for (final tag in tags) tag.id: tag.name};
    final buffer = StringBuffer('Prayer List\n');
    buffer.writeln('${'=' * 20}\n');

    for (final item in items) {
      final checkbox = item.isCompleted ? '[x]' : '[ ]';
      buffer.write('$checkbox ${item.text}');

      if (item.tagIds.isNotEmpty) {
        final tagNames = item.tagIds
            .map((id) => tagMap[id])
            .where((name) => name != null)
            .join(', ');
        if (tagNames.isNotEmpty) {
          buffer.write(' ($tagNames)');
        }
      }
      buffer.writeln();
    }

    await Share.share(buffer.toString());
  }
}
