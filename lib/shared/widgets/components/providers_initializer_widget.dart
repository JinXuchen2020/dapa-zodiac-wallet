import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zodiac/features/wallet/application/wallet_provider.dart';
// import 'package:zodiac/shared/providers/progress_report_provider.dart';

class ProvidersInitializerWidget extends ConsumerWidget {
  const ProvidersInitializerWidget({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(walletStateProvider);
    // ref.watch(progressReportStreamProvider);
    return child;
  }
}
