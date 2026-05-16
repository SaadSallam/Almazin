import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/backup/backup_service.dart';
import '../../../core/storage/app_storage.dart';
import '../../../core/theme/almazin_theme_tokens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_tokens_x.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_confirm_dialog.dart';
import '../../../shared/widgets/app_section.dart';
import '../../../shared/widgets/dashboard_page.dart';
import '../../theme/presentation/cubit/theme_cubit.dart';
import '../../theme/presentation/cubit/theme_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isExportLoading = false;
  bool _isImportLoading = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.almazinTokens;

    return DashboardPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSection(
            title: 'الإعدادات',
            subtitle: 'إعدادات التطبيق العامة',
            child: const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppSection(
            title: 'المظهر',
            subtitle: 'اختر وضع العرض. يُحفظ اختيارك محلياً ويُستعاد بعد تحديث الصفحة.',
            child: BlocBuilder<ThemeCubit, ThemeState>(
              buildWhen: (a, b) => a.themeMode != b.themeMode,
              builder: (context, state) {
                return _ThemeModeSelector(
                  selected: state.themeMode,
                  tokens: tokens,
                  scheme: scheme,
                  onChanged: (mode) {
                    context.read<ThemeCubit>().setThemeMode(mode);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppSection(
            title: 'النسخ الاحتياطي',
            subtitle: 'صدّر بيانات التطبيق كملف JSON احتياطي، أو استرجعها من نسخة سابقة.',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppButton(
                  label: 'تصدير نسخة احتياطية',
                  icon: Icons.file_upload_outlined,
                  variant: AppButtonVariant.secondary,
                  isLoading: _isExportLoading,
                  onPressed: _isExportLoading ? null : _onExport,
                ),
                AppButton(
                  label: 'استيراد نسخة احتياطية',
                  icon: Icons.file_download_outlined,
                  variant: AppButtonVariant.primary,
                  isLoading: _isImportLoading,
                  onPressed: _isImportLoading ? null : _onImport,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BackupService _createService() {
    return BackupService(
      dataBox: Hive.box<dynamic>(kAlmazinDataBox),
      settingsBox: Hive.box<dynamic>(kAlmazinSettingsBox),
    );
  }

  Future<void> _onExport() async {
    setState(() => _isExportLoading = true);
    try {
      final service = _createService();
      final jsonString = await service.exportBackup();
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      await FilePicker.saveFile(
        fileName: 'almazin_backup.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تصدير النسخة الاحتياطية بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء التصدير: $e')),
      );
    } finally {
      if (mounted) setState(() => _isExportLoading = false);
    }
  }

  Future<void> _onImport() async {
    setState(() => _isImportLoading = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      String jsonString;
      try {
        jsonString = utf8.decode(file.bytes!);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر قراءة الملف: $e')),
        );
        return;
      }

      final service = _createService();
      final validation = service.validate(jsonString);
      if (!validation.isValid) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validation.errorMessage ?? 'الملف غير صالح'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      if (!mounted) return;
      final confirmed = await showAppConfirmDialog(
        context: context,
        title: 'استيراد نسخة احتياطية',
        message: 'سيتم استبدال البيانات الحالية بما يلي:\n'
            '• ${validation.summary!.customerCount} عميل\n'
            '• ${validation.summary!.coffeeCount} صنف بن\n\n'
            'هل تريد المتابعة؟',
        confirmLabel: 'تأكيد الاستيراد',
        cancelLabel: 'إلغاء',
      );
      if (confirmed != true) return;

      final importResult = await service.importBackup(jsonString);
      if (!importResult.isValid) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(importResult.errorMessage ?? 'فشل الاستيراد'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      if (!mounted) return;
      final summary = importResult.summary!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم استيراد ${summary.customerCount} عميل و ${summary.coffeeCount} صنف بنجاح',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الاستيراد: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isImportLoading = false);
    }
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({
    required this.selected,
    required this.tokens,
    required this.scheme,
    required this.onChanged,
  });

  final ThemeMode selected;
  final AlmazinThemeTokens tokens;
  final ColorScheme scheme;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('فاتح'),
          icon: Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('داكن'),
          icon: Icon(Icons.dark_mode_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('النظام'),
          icon: Icon(Icons.settings_suggest_outlined),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (set) => onChanged(set.first),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.onPrimary;
          }
          return scheme.onSurface;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return scheme.surfaceContainerHighest.withValues(alpha: 0.35);
        }),
        side: WidgetStatePropertyAll(
          BorderSide(color: tokens.divider),
        ),
      ),
    );
  }
}
