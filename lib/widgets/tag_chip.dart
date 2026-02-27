import 'package:flutter/material.dart';

import '../models/tag.dart';

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.tag,
    this.selected = false,
    this.onTap,
  });

  final Tag tag;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(tag.colorValue);
    return FilterChip(
      label: Text(tag.name),
      selected: selected,
      onSelected: onTap != null ? (_) => onTap!() : null,
      selectedColor: color.withAlpha(80),
      checkmarkColor: color,
      side: BorderSide(color: color.withAlpha(120)),
    );
  }
}
