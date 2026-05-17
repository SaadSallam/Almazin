import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/navigation/app_paths.dart';
import '../../../core/storage/app_storage.dart';
import '../../../core/theme/theme_tokens_x.dart';
import '../../settings/presentation/pin_change_dialog.dart';
import '../domain/employee_access_guard.dart';
import '../domain/employee_pin_service.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen>
    with SingleTickerProviderStateMixin {
  final _pin = <int>[];
  String? _errorMessage;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  static const _maxPinLength = 6;
  static const _minPinLength = 4;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0, end: 0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigit(int digit) {
    if (_pin.length >= _maxPinLength) return;
    setState(() {
      _pin.add(digit);
      _errorMessage = null;
    });
    if (_pin.length >= _minPinLength) {
      _submit();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin.removeLast();
      _errorMessage = null;
    });
  }

  void _onClear() {
    setState(() {
      _pin.clear();
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    final pinStr = _pin.join();
    if (pinStr.length < _minPinLength) return;

    final box = Hive.box<dynamic>(kAlmazinSettingsBox);
    final valid = await EmployeePinService.verifyPin(box, pinStr);

    if (!mounted) return;

    if (valid) {
      EmployeeAccessGuard.unlock();
      context.go(AppPaths.employees);
    } else {
      setState(() {
        _errorMessage = 'رمز PIN غير صحيح';
        _pin.clear();
      });
      _shakeController.reset();
      _shakeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: tokens.surfaceDefault,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Spacer(flex: 2),
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: tokens.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'الموظفين',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'أدخل رمز PIN للوصول',
                  style: textTheme.bodyMedium?.copyWith(
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_maxPinLength, (i) {
                    final filled = i < _pin.length;
                    return Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? scheme.primary
                            : tokens.divider.withValues(alpha: 0.5),
                        border: !filled
                            ? Border.all(
                                color:
                                    tokens.divider.withValues(alpha: 0.3),
                              )
                            : null,
                      ),
                    );
                  }),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: textTheme.bodySmall?.copyWith(
                      color: tokens.errorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                _NumericKeypad(
                  onDigit: _onDigit,
                  onDelete: _onDelete,
                  onClear: _onClear,
                  confirmEnabled: _pin.length >= _minPinLength,
                  onConfirm: _submit,
                ),
                const Spacer(flex: 3),
                TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const PinChangeDialog(),
                  ),
                  child: Text(
                    'نسيت رمز PIN؟',
                    style: textTheme.bodySmall?.copyWith(
                      color: tokens.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({
    required this.onDigit,
    required this.onDelete,
    required this.onClear,
    required this.confirmEnabled,
    required this.onConfirm,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final bool confirmEnabled;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var col = 1; col <= 3; col++)
                  _KeypadButton(
                    label: '${row * 3 + col}',
                    onTap: () => onDigit(row * 3 + col),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _KeypadButton(
                label: '',
                icon: Icons.backspace_outlined,
                onTap: onDelete,
              ),
              _KeypadButton(
                label: '0',
                onTap: () => onDigit(0),
              ),
              _KeypadButton(
                label: '',
                icon: Icons.clear,
                onTap: onClear,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 240,
          child: Opacity(
            opacity: confirmEnabled ? 1.0 : 0.4,
            child: Material(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: confirmEnabled ? onConfirm : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'تأكيد',
                        style: textTheme.labelLarge?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: scheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.label,
    this.icon,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.almazinTokens;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: tokens.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 72,
            height: 56,
            alignment: Alignment.center,
            child: icon != null
                ? Icon(icon, size: 22, color: tokens.textSecondary)
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: tokens.textPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
