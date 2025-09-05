import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zodiac/shared/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zodiac/features/wallet/application/wallet_provider.dart';
import 'package:zodiac/features/wallet/domain/daemon_info_snapshot.dart';

part 'node_info_provider.g.dart';

@riverpod
Future<DaemonInfoSnapshot?> nodeInfo(Ref ref) async {
  final walletState = ref.watch(walletStateProvider);
  final walletRepository = walletState.nativeWalletRepository;
  if (walletRepository != null) {
    var info = await walletRepository.getDaemonInfo();

    // keep the state of a successful (only) request
    ref.keepAlive();

    return DaemonInfoSnapshot(
      topoHeight: info.topoHeight,
      pruned: info.prunedTopoHeight != null ? true : false,
      circulatingSupply: formatDapa(
        info.circulatingSupply,
        walletState.network,
      ),
      burnSupply: formatDapa(info.burnedSupply, walletState.network),
      averageBlockTime: Duration(milliseconds: info.averageBlockTime),
      mempoolSize: info.mempoolSize,
      blockReward: formatDapa(info.blockReward, walletState.network),
      version: info.version,
      network: info.network,
    );
  }
  return null;
}
