import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/storage/app_storage.dart';
import '../core/theme/app_fonts.dart';
import '../core/theme/app_theme.dart';
import '../features/theme/data/theme_repository_impl.dart';
import '../features/theme/presentation/cubit/theme_cubit.dart';
import '../features/theme/presentation/cubit/theme_state.dart';
import 'app_router.dart';

class AlmazinApp extends StatelessWidget {
  const AlmazinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(
        ThemeRepositoryImpl(Hive.box<dynamic>(kAlmazinSettingsBox)),
      ),
      child: const _ThemedApp(),
    );
  }
}

class _ThemedApp extends StatefulWidget {
  const _ThemedApp();

  @override
  State<_ThemedApp> createState() => _ThemedAppState();
}

class _ThemedAppState extends State<_ThemedApp> {
  late final GoRouter _router = AppRouter.create();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      buildWhen: (a, b) => a.themeMode != b.themeMode,
      builder: (context, state) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Almazin App',
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: state.themeMode,
          routerConfig: _router,
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontFamily: AppFonts.family),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}
