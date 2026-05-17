import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/backup/backup_service.dart';
import '../../../core/storage/app_storage.dart';
import '../../../core/theme/almazin_theme_tokens.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_tokens_x.dart';
import '../../../core/update/update_model.dart';
import '../../../core/update/update_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_confirm_dialog.dart';
import '../../../shared/widgets/app_section.dart';
import '../../../shared/widgets/dashboard_page.dart';
import '../../../shared/widgets/update_dialog.dart';
import 'pin_change_dialog.dart';
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
  bool _isCheckingUpdate = false;
  String _currentVersion = '...';
  String? _lastChecked;
  String? _updateError;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _currentVersion = info.version);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _currentVersion = '1.0.0');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.almazinTokens;
    final textTheme = Theme.of(context).textTheme;

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
            title: 'تحديث التطبيق',
            subtitle: 'تحقق من وجود إصدارات جديدة وحدّث التطبيق تلقائياً.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: tokens.surfaceContainer.withValues(alpha: 0.4),
                    borderRadius: AppRadius.card,
                    border: Border.all(color: tokens.divider.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الإصدار الحالي',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: tokens.textTertiary,
                                    fontSize: 11,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentVersion,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: tokens.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (_lastChecked != null)
                        Text(
                          'آخر تحقق: $_lastChecked',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: tokens.textTertiary,
                                fontSize: 11,
                              ),
                        ),
                    ],
                  ),
                ),
                if (_updateError != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _updateError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.errorColor,
                          fontSize: 12,
                        ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    AppButton(
                      label: _isCheckingUpdate ? 'جاري التحقق...' : 'التحقق من التحديثات',
                      icon: _isCheckingUpdate ? null : Icons.refresh_rounded,
                      variant: AppButtonVariant.primary,
                      isLoading: _isCheckingUpdate,
                      onPressed: _isCheckingUpdate ? null : _checkForUpdate,
                    ),
                  ],
                ),
              ],
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
          const SizedBox(height: AppSpacing.xxl),
          AppSection(
            title: 'أمان الموظفين',
            subtitle: 'قم بتعيين رمز PIN لحماية صفحة الموظفين من الوصول غير المصرح به.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: tokens.surfaceContainer.withValues(alpha: 0.4),
                    borderRadius: AppRadius.card,
                    border: Border.all(
                        color: tokens.divider.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline,
                          size: 20, color: tokens.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'حماية الموظفين',
                              style:
                                  textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: tokens.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'محمي برمز PIN',
                              style: textTheme.bodySmall?.copyWith(
                                color: tokens.successColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'تغيير رمز PIN',
                  icon: Icons.password_outlined,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const PinChangeDialog(),
                  ),
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

  Future<void> _checkForUpdate() async {
    setState(() {
      _isCheckingUpdate = true;
      _updateError = null;
    });

    try {
      final service = UpdateService(currentVersion: _currentVersion);
      final result = await service.checkForUpdate();

      if (!mounted) return;

      setState(() {
        _lastChecked = '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
        _isCheckingUpdate = false;
      });

      if (result.error != null) {
        setState(() => _updateError = result.error);
        return;
      }

      if (result.hasUpdate && result.latestRelease != null) {
        _showUpdateDialog(context, result.latestRelease!, service);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('التطبيق محدّث إلى آخر إصدار')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
          _updateError = 'خطأ: $e';
        });
      }
    }
  }

  void _showUpdateDialog(
    BuildContext context,
    ReleaseInfo release,
    UpdateService service,
  ) {
    final dialogKey = GlobalKey<UpdateDialogState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return UpdateDialog(
          key: dialogKey,
          currentVersion: _currentVersion,
          latestRelease: release,
          onUpdate: () async {
            final asset = release.setupAsset;
            if (asset == null) return;

            try {
              final installerPath = await service.downloadInstaller(
                asset,
                onProgress: (progress) {
                  dialogKey.currentState?.updateProgress(progress);
                },
              );
              if (!context.mounted) return;
              await service.installAndRestart(installerPath);
            } catch (e) {
              if (context.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('فشل التحديث: $e')),
                );
              }
            }
          },
          onRemindLater: () => Navigator.of(context).pop(),
          onSkipVersion: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
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
