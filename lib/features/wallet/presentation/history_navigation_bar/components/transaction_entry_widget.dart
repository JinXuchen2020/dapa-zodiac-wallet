import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zodiac/features/wallet/application/wallet_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:xelis_dart_sdk/xelis_dart_sdk.dart';
import 'package:zodiac/features/router/route_utils.dart';
import 'package:zodiac/features/settings/application/app_localizations_provider.dart';
import 'package:zodiac/features/wallet/presentation/history_navigation_bar/components/transaction_entry_screen.dart';
import 'package:zodiac/shared/theme/extensions.dart';
import 'package:zodiac/shared/theme/constants.dart';
import 'package:zodiac/shared/utils/utils.dart';
import 'package:zodiac/shared/resources/app_resources.dart';

class TransactionEntryWidget extends ConsumerStatefulWidget {
  const TransactionEntryWidget({required this.transactionEntry, super.key});

  final TransactionEntry transactionEntry;

  @override
  ConsumerState<TransactionEntryWidget> createState() =>
      _TransactionEntryWidgetState();
}

class _TransactionEntryWidgetState
    extends ConsumerState<TransactionEntryWidget> {
  late Icon icon;

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(appLocalizationsProvider);
    final network = ref.watch(
      walletStateProvider.select((state) => state.network),
    );
    final knownAssets = ref.watch(
      walletStateProvider.select((state) => state.knownAssets),
    );

    var topoheight = NumberFormat().format(widget.transactionEntry.topoheight);

    var labelThirdColumn = loc.amount;
    var contentThirdColumn = '';

    final entryType = widget.transactionEntry.txEntryType;

    switch (entryType) {
      case CoinbaseEntry():
        icon = Icon(Icons.square_rounded, size: 18);
        contentThirdColumn = '+${formatDapa(entryType.reward, network)}';
      case BurnEntry():
        icon = Icon(Icons.local_fire_department_rounded, size: 18);
        final fee = entryType.fee;
        contentThirdColumn = '-';
        if (entryType.asset == AppResources.dapaHash) {
          contentThirdColumn += formatDapa(entryType.amount + fee, network);
        } else {
          if (knownAssets.containsKey(entryType.asset)) {
            contentThirdColumn += formatCoin(
              entryType.amount,
              knownAssets[entryType.asset]!.decimals,
              knownAssets[entryType.asset]!.ticker,
            );
          } else {
            contentThirdColumn += entryType.amount.toString();
          }
        }
      case IncomingEntry():
        icon = Icon(Icons.call_received_rounded, size: 18);
        if (entryType.transfers.length == 1) {
          contentThirdColumn = '+';
          final transfer = entryType.transfers[0];
          if (transfer.asset == AppResources.dapaHash) {
            contentThirdColumn += formatDapa(transfer.amount, network);
          } else {
            if (knownAssets.containsKey(transfer.asset)) {
              contentThirdColumn += formatCoin(
                transfer.amount,
                knownAssets[transfer.asset]!.decimals,
                knownAssets[transfer.asset]!.ticker,
              );
            } else {
              contentThirdColumn += transfer.amount.toString();
            }
          }
        } else {
          contentThirdColumn = loc.multi_transfer;
        }
      case OutgoingEntry():
        icon = Icon(Icons.call_made_rounded, size: 18);
        if (entryType.transfers.length == 1) {
          final transfer = entryType.transfers[0];
          final fee = entryType.fee;
          contentThirdColumn = '-';
          if (transfer.asset == AppResources.dapaHash) {
            contentThirdColumn += formatDapa(transfer.amount + fee, network);
          } else {
            if (knownAssets.containsKey(transfer.asset)) {
              contentThirdColumn += formatCoin(
                transfer.amount,
                knownAssets[transfer.asset]!.decimals,
                knownAssets[transfer.asset]!.ticker,
              );
            } else {
              contentThirdColumn += transfer.amount.toString();
            }
          }
        } else {
          contentThirdColumn = loc.multi_transfer;
        }
      case MultisigEntry():
        icon = Icon(Icons.call_made_rounded, size: 18);
        labelThirdColumn = loc.type.toLowerCase();
        contentThirdColumn = (entryType.participants.isEmpty)
            ? loc.multisig_deleted
            : loc.multisig_activated;
      case InvokeContractEntry():
        icon = Icon(Icons.call_made_rounded, size: 18);
        labelThirdColumn = loc.type.toLowerCase();
        contentThirdColumn = loc.invoked_contract;
      case DeployContractEntry():
        icon = Icon(Icons.call_made_rounded, size: 18);
        labelThirdColumn = loc.type.toLowerCase();
        contentThirdColumn = loc.deployed_contract;
    }

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spaces.medium,
          Spaces.small,
          Spaces.medium,
          Spaces.small,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            icon,
            const SizedBox(width: Spaces.medium),
            Column(
              children: [
                Text(
                  loc.topoheight.toLowerCase(),
                  style: context.labelMedium?.copyWith(
                    color: context.moreColors.mutedColor,
                  ),
                ),
                const SizedBox(height: Spaces.extraSmall),
                SelectableText(topoheight, style: context.bodyLarge),
              ],
            ),
            const Spacer(),
            Column(
              children: [
                Text(
                  labelThirdColumn,
                  style: context.labelMedium?.copyWith(
                    color: context.moreColors.mutedColor,
                  ),
                ),
                const SizedBox(height: Spaces.extraSmall),
                SelectableText(contentThirdColumn, style: context.bodyLarge),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () => _showTransactionEntry(widget.transactionEntry),
              icon: const Icon(Icons.info_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionEntry(TransactionEntry transactionEntry) {
    context.push(
      AuthAppScreen.transactionEntry.toPath,
      extra: TransactionEntryScreenExtra(transactionEntry),
    );
  }
}
