import 'package:flutter/material.dart';

Future<String?> showSavePercentageBlendDialog(BuildContext context) async {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  try {
    return await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('حفظ كتوليفة عميل'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'اسم التوليفة',
                hintText: 'مثال: توليفة المحل اليومية',
              ),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'اسم التوليفة مطلوب';
                if (t.length > 120) return 'الاسم طويل جداً';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() != true) return;
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  } finally {
    controller.dispose();
  }
}
