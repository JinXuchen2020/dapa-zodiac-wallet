import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zodiac/features/authentication/application/biometric_auth_provider.dart';
import 'package:zodiac/features/settings/application/app_localizations_provider.dart';
import 'package:zodiac/features/settings/application/settings_state_provider.dart';
import 'package:zodiac/shared/providers/snackbar_queue_provider.dart';
import 'package:zodiac/shared/theme/constants.dart';
import 'package:zodiac/shared/theme/extensions.dart';
import 'package:zodiac/shared/widgets/components/generic_dialog.dart';
import 'package:zodiac/shared/widgets/components/warning_widget.dart';
import 'package:go_router/go_router.dart';

class BurnWarningDialog extends ConsumerWidget {
  const BurnWarningDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.read(appLocalizationsProvider);

    return GenericDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WarningWidget([loc.burn_unlock_warning_message]),
          const SizedBox(height: Spaces.medium),
          Text(
            loc.do_you_want_to_activate_burn_transfer,
            style: context.bodyMedium?.copyWith(
              color: context.moreColors.mutedColor,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(settingsProvider.notifier).setUnlockBurn(false);
            context.pop();
          },
          child: Text(loc.cancel_button),
        ),
        TextButton(
          onPressed: () => startWithBiometricAuth(
            ref,
            callback: _unlockBurn,
            reason: loc.please_authenticate_burn_tx,
            closeCurrentDialog: true,
          ),
          child: Text(loc.confirm_button),
        ),
      ],
    );
  }

  void _unlockBurn(WidgetRef ref) {
    final loc = ref.read(appLocalizationsProvider);
    ref.read(settingsProvider.notifier).setUnlockBurn(true);
    ref.read(snackBarQueueProvider.notifier).showInfo(loc.burn_transfer_unlock);
  }
}
