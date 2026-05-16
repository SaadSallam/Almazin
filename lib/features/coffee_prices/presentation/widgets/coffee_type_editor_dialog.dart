import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:almazin_app/features/coffee_prices/domain/coffee_type.dart';
import 'package:almazin_app/features/coffee_prices/domain/price_input_parser.dart';
import 'package:almazin_app/features/coffee_prices/presentation/cubit/coffee_prices_cubit.dart';
import 'package:almazin_app/shared/widgets/app_button.dart';

Future<void> showCoffeeTypeEditor({
  required BuildContext context,
  required CoffeePricesCubit cubit,
  CoffeeType? existing,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: cubit,
        child: _CoffeeTypeEditorDialog(existing: existing),
      );
    },
  );
}

class _CoffeeTypeEditorDialog extends StatefulWidget {
  const _CoffeeTypeEditorDialog({this.existing});

  final CoffeeType? existing;

  @override
  State<_CoffeeTypeEditorDialog> createState() => _CoffeeTypeEditorDialogState();
}

class _CoffeeTypeEditorDialogState extends State<_CoffeeTypeEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _notes;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _price = TextEditingController(
      text: e == null ? '' : _formatInitialPrice(e.pricePerKilogram),
    );
    _notes = TextEditingController(text: e?.notes ?? '');
  }

  String _formatInitialPrice(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final price = PriceInputParser.tryParse(_price.text);
    if (price == null) {
      setState(() {});
      return;
    }

    setState(() => _saving = true);
    final cubit = context.read<CoffeePricesCubit>();
    final ok = await cubit.save(
      existingId: widget.existing?.id,
      name: _name.text,
      pricePerKilogram: price,
      notes: _notes.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEdit = widget.existing != null;

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
                    isEdit ? 'تعديل صنف بن' : 'إضافة صنف بن',
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'اسم البن',
                    ),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'اسم البن مطلوب';
                      if (t.length > 120) return 'اسم البن طويل جداً';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'سعر الكيلو (ج.م)',
                      hintText: 'مثال: 125 أو 125.5',
                    ),
                    validator: (v) {
                      final raw = v?.trim() ?? '';
                      if (raw.isEmpty) return 'سعر الكيلو مطلوب';
                      final parsed = PriceInputParser.tryParse(raw);
                      if (parsed == null) return 'أدخل رقماً صالحاً';
                      if (parsed <= 0) return 'السعر يجب أن يكون أكبر من صفر';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notes,
                    minLines: 2,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) {
                      final t = v ?? '';
                      if (t.length > 2000) return 'الملاحظات طويلة جداً';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'إلغاء',
                          variant: AppButtonVariant.secondary,
                          onPressed: _saving ? null : () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: isEdit ? 'حفظ' : 'إضافة',
                          variant: AppButtonVariant.primary,
                          onPressed: _saving ? null : _submit,
                        ),
                      ),
                    ],
                  ),
                  if (_saving) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(color: scheme.primary),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
