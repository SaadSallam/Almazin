import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/app_storage.dart';
import '../../../core/theme/theme_tokens_x.dart';
import '../../employees/domain/employee_pin_service.dart';

class PinChangeDialog extends StatefulWidget {
  const PinChangeDialog({super.key});

  @override
  State<PinChangeDialog> createState() => _PinChangeDialogState();
}

class _PinChangeDialogState extends State<PinChangeDialog> {
  final _currentPin = <int>[];
  final _newPin = <int>[];
  final _confirmPin = <int>[];

  var _step = 0;
  String? _errorMessage;

  static const _maxPinLength = 6;
  static const _minPinLength = 4;

  String get _title {
    return switch (_step) {
      0 => 'الرمز الحالي',
      1 => 'الرمز الجديد',
      2 => 'تأكيد الرمز الجديد',
      _ => '',
    };
  }

  List<int> get _currentInput {
    return switch (_step) {
      0 => _currentPin,
      1 => _newPin,
      2 => _confirmPin,
      _ => _currentPin,
    };
  }

  void _onDigit(int digit) {
    final input = _currentInput;
    if (input.length >= _maxPinLength) return;
    setState(() {
      input.add(digit);
      _errorMessage = null;
    });
    if (input.length >= _minPinLength) {
      _advance();
    }
  }

  void _onDelete() {
    final input = _currentInput;
    if (input.isEmpty) return;
    setState(() {
      input.removeLast();
      _errorMessage = null;
    });
  }

  Future<void> _advance() async {
    switch (_step) {
      case 0:
        final box = Hive.box<dynamic>(kAlmazinSettingsBox);
        final valid =
            await EmployeePinService.verifyPin(box, _currentPin.join());
        if (!mounted) return;
        if (valid) {
          setState(() {
            _step = 1;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage = 'الرمز الحالي غير صحيح';
            _currentPin.clear();
          });
        }
      case 1:
        setState(() {
          _step = 2;
          _errorMessage = null;
        });
      case 2:
        final newPinStr = _newPin.join();
        final confirmStr = _confirmPin.join();
        if (newPinStr != confirmStr) {
          setState(() {
            _errorMessage = 'الرمز غير متطابق';
            _confirmPin.clear();
          });
          return;
        }
        final box = Hive.box<dynamic>(kAlmazinSettingsBox);
        await EmployeePinService.changePin(box, _currentPin.join(), newPinStr);
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تغيير رمز PIN بنجاح')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_maxPinLength, (i) {
                final filled = i < _currentInput.length;
                return Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? scheme.primary
                        : tokens.divider.withValues(alpha: 0.5),
                    border: !filled
                        ? Border.all(
                            color: tokens.divider.withValues(alpha: 0.3),
                          )
                        : null,
                  ),
                );
              }),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: textTheme.bodySmall?.copyWith(
                  color: tokens.errorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 24),
            _Keypad(
              onDigit: _onDigit,
              onDelete: _onDelete,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إلغاء',
                style: textTheme.bodySmall?.copyWith(
                  color: tokens.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onDigit,
    required this.onDelete,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;

    Widget btn(String label, {VoidCallback? onTap, IconData? icon}) {
      return Padding(
        padding: const EdgeInsets.all(3),
        child: Material(
          color: tokens.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Container(
              width: 64,
              height: 48,
              alignment: Alignment.center,
              child: icon != null
                  ? Icon(icon, size: 20, color: tokens.textSecondary)
                  : Text(
                      label,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 3; row++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var col = 1; col <= 3; col++)
                btn('${row * 3 + col}',
                    onTap: () => onDigit(row * 3 + col)),
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            btn('', icon: Icons.backspace_outlined, onTap: onDelete),
            btn('0', onTap: () => onDigit(0)),
            const SizedBox(width: 64 + 6, height: 48 + 6),
          ],
        ),
      ],
    );
  }
}
