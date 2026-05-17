import 'package:flutter/material.dart';

import '../../../../core/theme/theme_tokens_x.dart';

class WeekSelector extends StatelessWidget {
  const WeekSelector({
    super.key,
    required this.weekStart,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime weekStart;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  String _formatWeek(DateTime start) {
    final end = start.add(const Duration(days: 6));
    final startStr = '${start.day}/${start.month}/${start.year}';
    final endStr = '${end.day}/${end.month}/${end.year}';
    return '$startStr - $endStr';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.surfaceDefault,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: onPrevious,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
          const SizedBox(width: 8),
          Text(
            'أسبوع ${_formatWeek(weekStart)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: onNext,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}
