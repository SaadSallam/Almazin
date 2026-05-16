import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:almazin_app/core/keyboard/app_shortcuts.dart';
import 'package:almazin_app/features/customers/domain/customer.dart';
import 'package:almazin_app/features/customers/presentation/cubit/customer_detail_cubit.dart';
import 'package:almazin_app/features/customers/presentation/cubit/customer_detail_state.dart';
import 'package:almazin_app/shared/widgets/app_button.dart';
import 'package:almazin_app/shared/widgets/app_section.dart';

class CustomerProfileSection extends StatelessWidget {
  const CustomerProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerDetailCubit, CustomerDetailState>(
      buildWhen: (a, b) => a.customer != b.customer || a.isSavingProfile != b.isSavingProfile,
      builder: (context, state) {
        final customer = state.customer;
        if (customer == null) return const SizedBox.shrink();

        return _CustomerProfileForm(
          key: ValueKey(customer.id),
          customer: customer,
          isSaving: state.isSavingProfile,
        );
      },
    );
  }
}

class _CustomerProfileForm extends StatefulWidget {
  const _CustomerProfileForm({
    super.key,
    required this.customer,
    required this.isSaving,
  });

  final Customer customer;
  final bool isSaving;

  @override
  State<_CustomerProfileForm> createState() => _CustomerProfileFormState();
}

class _CustomerProfileFormState extends State<_CustomerProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _notes;
  final _notesFocusNode = FocusNode();

  bool get _isNotesFocused => _notesFocusNode.hasPrimaryFocus;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.customer.name);
    _phone = TextEditingController(text: widget.customer.phone);
    _address = TextEditingController(text: widget.customer.address);
    _notes = TextEditingController(text: widget.customer.notes);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _notes.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: Shortcuts(
        shortcuts: {
          SingleActivator(LogicalKeyboardKey.keyS, control: true): const SaveIntent(),
        },
        child: Actions(
          actions: {
            SaveIntent: CallbackAction<SaveIntent>(onInvoke: (_) {
              if (_isNotesFocused) return null;
              _submit();
              return null;
            }),
          },
          child: AppSection(
            title: 'بيانات العميل',
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                    focusNode: _notesFocusNode,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppButton(
                    label: 'حفظ البيانات',
                    icon: Icons.save_outlined,
                    variant: AppButtonVariant.primary,
                    onPressed: widget.isSaving
                        ? null
                        : _submit,
                  ),
                  if (widget.isSaving) ...[
                    const SizedBox(height: 10),
                    const LinearProgressIndicator(minHeight: 3),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    final cubit = context.read<CustomerDetailCubit>();
    await cubit.saveProfile(
      name: _name.text,
      phone: _phone.text,
      address: _address.text,
      notes: _notes.text,
    );
  }
}
