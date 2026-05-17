import 'package:flutter/material.dart';

import '../../../../core/theme/theme_tokens_x.dart';
import '../../../../shared/widgets/app_button.dart';

class WeekCloseDialog extends StatelessWidget {
  const WeekCloseDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tokens.warningColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 32,
                color: tokens.warningColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'إغلاق الأسبوع',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'هل أنت متأكد من إغلاق هذا الأسبوع؟ سيتم حفظ لقطة الرواتب ولن يمكن تعديل الحضور بعد ذلك.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'إلغاء',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'إغلاق الأسبوع',
                    variant: AppButtonVariant.primary,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
