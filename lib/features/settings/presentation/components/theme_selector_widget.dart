import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zodiac/features/settings/application/app_localizations_provider.dart';
import 'package:zodiac/features/settings/application/settings_state_provider.dart';
import 'package:zodiac/features/settings/domain/settings_state.dart';
import 'package:zodiac/features/settings/domain/theme_translate_name.dart';
import 'package:zodiac/shared/theme/extensions.dart';

const List<AppTheme> themes = <AppTheme>[
  AppTheme.dapa,
  AppTheme.dark,
  AppTheme.light,
];

class ThemeSelectorWidget extends ConsumerWidget {
  const ThemeSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(settingsProvider.select((state) => state.theme));
    final loc = ref.watch(appLocalizationsProvider);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      shape: Border.all(color: Colors.transparent, width: 0),
      collapsedShape: Border.all(color: Colors.transparent, width: 0),
      title: Text(loc.theme, style: context.titleLarge),
      subtitle: Text(
        translateThemeName(loc, theme),
        style: context.titleMedium!.copyWith(color: context.colors.primary),
      ),
      children: List<ListTile>.generate(
        themes.length,
        (index) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            translateThemeName(loc, themes[index]),
            style: context.titleMedium,
          ),
          leading: Radio<AppTheme>(
            value: themes[index],
            groupValue: theme,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setTheme(value);
              }
            },
          ),
        ),
      ),
    );
  }
}
