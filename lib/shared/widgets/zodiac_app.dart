import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zodiac/features/logger/logger.dart';
import 'package:zodiac/src/generated/l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zodiac/features/authentication/application/authentication_service.dart';
import 'package:zodiac/features/router/router.dart';
import 'package:zodiac/features/settings/application/settings_state_provider.dart';
import 'package:zodiac/features/settings/domain/settings_state.dart';
import 'package:zodiac/shared/resources/app_resources.dart';
import 'package:zodiac/shared/theme/dark.dart';
import 'package:zodiac/shared/theme/light.dart';
import 'package:zodiac/shared/theme/xelis.dart';
import 'package:zodiac/shared/widgets/app_initializer.dart';

class Zodiac extends ConsumerStatefulWidget {
  const Zodiac({super.key});

  @override
  ConsumerState<Zodiac> createState() => _ZodiacState();
}

class _ZodiacState extends ConsumerState<Zodiac> with WindowListener {
  final _lightTheme = lightTheme();
  final _darkTheme = darkTheme();
  final _dapaTheme = dapaTheme();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final appTheme = ref.watch(settingsProvider.select((state) => state.theme));

    // using kDebugMode and call func every render to hot reload the theme
    ThemeData themeData;
    switch (appTheme) {
      case AppTheme.dapa:
        themeData = kDebugMode ? dapaTheme() : _dapaTheme;
      case AppTheme.dark:
        themeData = kDebugMode ? darkTheme() : _darkTheme;
      case AppTheme.light:
        themeData = kDebugMode ? lightTheme() : _lightTheme;
    }

    return MaterialApp.router(
      title: AppResources.dapaWalletName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: themeData,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return AppInitializer(child: child!);
      },
    );
  }

  @override
  Future<void> onWindowClose() async {
    await ref.read(authenticationProvider.notifier).logout();
    talker.disable();
  }
}
