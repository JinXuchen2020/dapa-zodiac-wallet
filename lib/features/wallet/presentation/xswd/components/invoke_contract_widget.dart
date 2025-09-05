import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zodiac/features/settings/application/app_localizations_provider.dart';
import 'package:zodiac/features/wallet/presentation/xswd/components/invoke_widget.dart';
import 'package:zodiac/features/wallet/presentation/xswd/components/transaction_builder_mixin.dart';
import 'package:zodiac/shared/theme/constants.dart';
import 'package:zodiac/shared/theme/extensions.dart';
import 'package:xelis_dart_sdk/xelis_dart_sdk.dart';

class InvokeContractBuilderWidget extends ConsumerStatefulWidget {
  final InvokeContractBuilder invokeContractBuilder;

  const InvokeContractBuilderWidget({
    super.key,
    required this.invokeContractBuilder,
  });

  @override
  ConsumerState<InvokeContractBuilderWidget> createState() =>
      _InvokeContractBuilderWidgetState();
}

class _InvokeContractBuilderWidgetState
    extends ConsumerState<InvokeContractBuilderWidget>
    with TransactionBuilderMixin {
  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(appLocalizationsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loc.invoke_contract,
              style: context.bodyLarge!.copyWith(
                color: context.moreColors.mutedColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spaces.medium),
        buildLabeledText(
          context,
          loc.contract,
          widget.invokeContractBuilder.contract,
        ),
        InvokeWidget(
          maxGas: widget.invokeContractBuilder.maxGas,
          chunkId: widget.invokeContractBuilder.chunkId,
          deposits: widget.invokeContractBuilder.deposits,
          parameters: widget.invokeContractBuilder.parameters,
        ),
      ],
    );
  }
}
