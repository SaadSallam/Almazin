import 'package:flutter/material.dart';

import 'app_button.dart';

Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'حذف',
  String cancelLabel = 'إلغاء',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          AppButton(
            label: confirmLabel,
            variant: AppButtonVariant.primary,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
