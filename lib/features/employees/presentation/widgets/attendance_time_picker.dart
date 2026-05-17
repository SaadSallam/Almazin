import 'package:flutter/material.dart';

import '../../../../core/theme/theme_tokens_x.dart';

class AttendanceTimePicker extends StatelessWidget {
  const AttendanceTimePicker({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime(BuildContext context) async {
    final now = value ?? DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final baseDate = value ?? DateTime.now();
      onChanged(DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        picked.hour,
        picked.minute,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;

    return GestureDetector(
      onTap: () => _pickTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: value != null
              ? tokens.primary.withOpacity(0.05)
              : tokens.surfaceContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: value != null ? tokens.primary : tokens.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatTime(value),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: value != null ? tokens.textPrimary : tokens.textTertiary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.access_time,
              size: 14,
              color: tokens.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
