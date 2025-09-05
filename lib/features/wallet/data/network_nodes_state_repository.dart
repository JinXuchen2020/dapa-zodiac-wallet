import 'package:zodiac/shared/storage/persistent_state.dart';
import 'package:zodiac/features/wallet/domain/network_nodes_state.dart';
import 'package:zodiac/features/logger/logger.dart';
import 'package:zodiac/shared/resources/app_resources.dart';
import 'package:zodiac/shared/storage/shared_preferences/zodiac_shared_preferences.dart';

class NetworkNodesStateRepository extends PersistentState<NetworkNodesState> {
  NetworkNodesStateRepository(this.zodiacSharedPreferences);

  ZodiacSharedPreferences zodiacSharedPreferences;
  static const storageKey = 'network_nodes';

  @override
  NetworkNodesState fromStorage() {
    try {
      final value = zodiacSharedPreferences.get(key: storageKey);
      if (value == null) {
        return NetworkNodesState(
          mainnetAddress: AppResources.mainnetNodes.first,
          mainnetNodes: AppResources.mainnetNodes,
          testnetAddress: AppResources.testnetNodes.first,
          testnetNodes: AppResources.testnetNodes,
          devAddress: AppResources.devNodes.first,
          devNodes: AppResources.devNodes,
        );
      }
      return NetworkNodesState.fromJson(value as Map<String, dynamic>);
    } catch (e) {
      talker.critical('NetworkNodesStateRepository: $e');
      rethrow;
    }
  }

  @override
  Future<void> localDelete() async {
    await zodiacSharedPreferences.delete(key: storageKey);
  }

  @override
  Future<void> localSave(NetworkNodesState state) async {
    final value = state.toJson();
    await zodiacSharedPreferences.save(key: storageKey, value: value);
  }
}
