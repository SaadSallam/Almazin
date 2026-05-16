import 'package:flutter/material.dart';

import 'package:almazin_app/shared/widgets/app_button.dart';

Future<CustomerEditorResult?> showCustomerEditorDialog({
  required BuildContext context,
  String? initialName,
  String? initialPhone,
  String? initialAddress,
  String? initialNotes,
  bool isEdit = false,
}) async {
  return showDialog<CustomerEditorResult>(
    context: context,
    builder: (dialogContext) => _CustomerEditorDialog(
      initialName: initialName ?? '',
      initialPhone: initialPhone ?? '',
      initialAddress: initialAddress ?? '',
      initialNotes: initialNotes ?? '',
      isEdit: isEdit,
    ),
  );
}

class CustomerEditorResult {
  const CustomerEditorResult({
    required this.name,
    required this.phone,
    required this.address,
    required this.notes,
  });

  final String name;
  final String phone;
  final String address;
  final String notes;
}

class _CustomerEditorDialog extends StatefulWidget {
  const _CustomerEditorDialog({
    required this.initialName,
    required this.initialPhone,
    required this.initialAddress,
    required this.initialNotes,
    required this.isEdit,
  });

  final String initialName;
  final String initialPhone;
  final String initialAddress;
  final String initialNotes;
  final bool isEdit;

  @override
  State<_CustomerEditorDialog> createState() => _CustomerEditorDialogState();
}

class _CustomerEditorDialogState extends State<_CustomerEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _phone = TextEditingController(text: widget.initialPhone);
    _address = TextEditingController(text: widget.initialAddress);
    _notes = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(
      CustomerEditorResult(
        name: _name.text,
        phone: _phone.text,
        address: _address.text,
        notes: _notes.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.isEdit ? 'تعديل بيانات العميل' : 'إضافة عميل',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'الاسم'),
                    validator: (v) {
                      if ((v?.trim() ?? '').isEmpty) return 'الاسم مطلوب';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'الهاتف'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _address,
                    decoration: const InputDecoration(labelText: 'العنوان'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notes,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'إلغاء',
                          variant: AppButtonVariant.secondary,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: widget.isEdit ? 'حفظ' : 'إضافة',
                          variant: AppButtonVariant.primary,
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
