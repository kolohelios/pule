import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tag_provider.dart';
import 'tag_chip.dart';

class TagPicker extends ConsumerWidget {
  const TagPicker({
    super.key,
    required this.selectedTagIds,
    required this.onChanged,
  });

  final Set<String> selectedTagIds;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);

    return tagsAsync.when(
      data: (tags) {
        if (tags.isEmpty) return const SizedBox.shrink();
        return Wrap(
          spacing: 8,
          children: tags.map((tag) {
            final isSelected = selectedTagIds.contains(tag.id);
            return TagChip(
              tag: tag,
              selected: isSelected,
              onTap: () {
                final newSet = Set<String>.from(selectedTagIds);
                if (isSelected) {
                  newSet.remove(tag.id);
                } else {
                  newSet.add(tag.id);
                }
                onChanged(newSet);
              },
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
