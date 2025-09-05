import 'dart:async';
import 'dart:convert';

import 'package:zodiac/features/wallet/domain/multisig/multisig_state.dart';
import 'package:zodiac/features/wallet/domain/transaction_summary.dart';
import 'package:zodiac/src/generated/rust_bridge/api/models/address_book_dtos.dart';
import 'package:zodiac/src/generated/rust_bridge/api/models/wallet_dtos.dart';
import 'package:zodiac/src/generated/rust_bridge/api/models/xswd_dtos.dart';
import 'package:zodiac/src/generated/rust_bridge/api/models/network.dart';
import 'package:zodiac/src/generated/rust_bridge/api/precomputed_tables.dart';
import 'package:xelis_dart_sdk/xelis_dart_sdk.dart' as sdk;
import 'package:zodiac/features/wallet/domain/event.dart';
import 'package:zodiac/features/logger/logger.dart';
import 'package:zodiac/src/generated/rust_bridge/api/wallet.dart';

class NativeWalletRepository {
  NativeWalletRepository._internal(this._dapaWallet);

  final DapaWallet _dapaWallet;

  static Future<NativeWalletRepository> create(
    String walletPath,
    String pwd,
    Network network, {
    String? precomputeTablesPath,
    required PrecomputedTableType precomputedTableType,
  }) async {
    final dapaWallet = await createDapaWallet(
      name: walletPath,
      password: pwd,
      network: network,
      precomputedTablesPath: precomputeTablesPath,
      precomputedTableType: precomputedTableType,
    );
    talker.info('new DAPA Wallet created: $walletPath');
    return NativeWalletRepository._internal(dapaWallet);
  }

  static Future<NativeWalletRepository> recoverFromSeed(
    String walletPath,
    String pwd,
    Network network, {
    required String seed,
    String? precomputeTablesPath,
    required PrecomputedTableType precomputedTableType,
  }) async {
    final dapaWallet = await createDapaWallet(
      name: walletPath,
      password: pwd,
      seed: seed,
      network: network,
      precomputedTablesPath: precomputeTablesPath,
      precomputedTableType: precomputedTableType,
    );
    talker.info('DAPA Wallet recovered from seed: $walletPath');
    return NativeWalletRepository._internal(dapaWallet);
  }

  static Future<NativeWalletRepository> recoverFromPrivateKey(
    String walletPath,
    String pwd,
    Network network, {
    required String privateKey,
    String? precomputeTablesPath,
    required PrecomputedTableType precomputedTableType,
  }) async {
    final dapaWallet = await createDapaWallet(
      name: walletPath,
      password: pwd,
      privateKey: privateKey,
      network: network,
      precomputedTablesPath: precomputeTablesPath,
      precomputedTableType: precomputedTableType,
    );
    talker.info('DAPA Wallet recovered from private key: $walletPath');
    return NativeWalletRepository._internal(dapaWallet);
  }

  static Future<NativeWalletRepository> open(
    String walletPath,
    String pwd,
    Network network, {
    String? precomputeTablesPath,
    required PrecomputedTableType precomputedTableType,
  }) async {
    final dapaWallet = await openDapaWallet(
      name: walletPath,
      password: pwd,
      network: network,
      precomputedTablesPath: precomputeTablesPath,
      precomputedTableType: precomputedTableType,
    );
    talker.info('DAPA Wallet open: $walletPath');
    return NativeWalletRepository._internal(dapaWallet);
  }

  Future<void> updatePrecomputedTables(
    String precomputeTablesPath,
    PrecomputedTableType precomputedTableType,
  ) async {
    await _dapaWallet.updatePrecomputedTables(
      precomputedTablesPath: precomputeTablesPath,
      precomputedTableType: precomputedTableType,
    );
  }

  Future<PrecomputedTableType> getPrecomputedTablesType() async {
    return _dapaWallet.getPrecomputedTablesType();
  }

  Future<void> close() async {
    await _dapaWallet.close();
  }

  void dispose() {
    _dapaWallet.dispose();
    if (_dapaWallet.isDisposed) talker.info('Rust Wallet disposed');
  }

  DapaWallet get nativeWallet => _dapaWallet;

  String get address => _dapaWallet.getAddressStr();

  Future<BigInt> get nonce => _dapaWallet.getNonce();

  Future<bool> get isOnline => _dapaWallet.isOnline();

  Network get network => _dapaWallet.getNetwork();

  Future<void> setOnline({required String daemonAddress}) async {
    await _dapaWallet.onlineMode(daemonAddress: daemonAddress);
    talker.info('DAPA Wallet connected to: $daemonAddress');
  }

  Future<void> setOffline() async {
    await _dapaWallet.offlineMode();
    talker.info('DAPA Wallet offline');
  }

  Stream<Event> convertRawEvents() async* {
    final rawEventStream = _dapaWallet.eventsStream();

    await for (final rawData in rawEventStream) {
      final json = jsonDecode(rawData);
      try {
        final eventType = sdk.WalletEvent.fromStr(json['event'] as String);
        switch (eventType) {
          case sdk.WalletEvent.newTopoHeight:
            final newTopoheight = Event.newTopoheight(
              json['data']['topoheight'] as int,
            );
            yield newTopoheight;
          case sdk.WalletEvent.newAsset:
            final newAsset = Event.newAsset(
              sdk.RPCAssetData.fromJson(json['data'] as Map<String, dynamic>),
            );
            yield newAsset;
          case sdk.WalletEvent.newTransaction:
            final newTransaction = Event.newTransaction(
              sdk.TransactionEntry.fromJson(
                json['data'] as Map<String, dynamic>,
              ),
            );
            yield newTransaction;
          case sdk.WalletEvent.balanceChanged:
            final balanceChanged = Event.balanceChanged(
              sdk.BalanceChangedEvent.fromJson(
                json['data'] as Map<String, dynamic>,
              ),
            );
            yield balanceChanged;
          case sdk.WalletEvent.rescan:
            final rescan = Event.rescan(
              json['data']['start_topoheight'] as int,
            );
            yield rescan;
          case sdk.WalletEvent.online:
            yield const Event.online();
          case sdk.WalletEvent.offline:
            yield const Event.offline();
          case sdk.WalletEvent.historySynced:
            final historySynced = Event.historySynced(
              json['data']['topoheight'] as int,
            );
            yield historySynced;
          case sdk.WalletEvent.syncError:
            final syncError = Event.syncError(
              json['data']['message'] as String,
            );
            yield syncError;
          case sdk.WalletEvent.trackAsset:
            final trackAsset = Event.trackAsset(
              json['data']['asset'] as String,
            );
            yield trackAsset;
          case sdk.WalletEvent.untrackAsset:
            final untrackAsset = Event.untrackAsset(
              json['data']['asset'] as String,
            );
            yield untrackAsset;
        }
      } catch (e) {
        talker.error('Unknown event: ${json['event']}');
        continue;
      }
    }
  }

  Future<String> formatCoin(int amount, [String? assetHash]) async {
    return _dapaWallet.formatCoin(
      atomicAmount: BigInt.from(amount),
      assetHash: assetHash,
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return _dapaWallet.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  Future<String> getSeed({int? languageIndex}) async {
    return _dapaWallet.getSeed(
      languageIndex: languageIndex == null ? null : BigInt.from(languageIndex),
    );
  }

  Future<void> isValidPassword(String password) async {
    return _dapaWallet.isValidPassword(password: password);
  }

  Future<String> getXelisBalance() async {
    return _dapaWallet.getDapaBalance();
  }

  Future<bool> hasAssetBalance(String assetHash) async {
    return _dapaWallet.hasAssetBalance(asset: assetHash);
  }

  Future<Map<String, String>> getTrackedBalances() async {
    return _dapaWallet.getTrackedBalances();
  }

  Future<Map<String, sdk.AssetData>> getKnownAssets() async {
    final rawData = await _dapaWallet.getKnownAssets();
    return {
      for (final entry in rawData.entries)
        entry.key: sdk.AssetData.fromJson(
          jsonDecode(entry.value) as Map<String, dynamic>,
        ),
    };
  }

  Future<bool> trackAsset(String assetHash) async {
    final result = await _dapaWallet.trackAsset(asset: assetHash);
    return result;
  }

  Future<bool> untrackAsset(String assetHash) async {
    final result = await _dapaWallet.untrackAsset(asset: assetHash);
    return result;
  }

  Future<int> getHistoryCount() async {
    final count = await _dapaWallet.getHistoryCount();
    if (count.isValidInt) {
      return count.toInt();
    } else {
      throw Exception('Invalid history count');
    }
  }

  Future<List<sdk.TransactionEntry>> history(HistoryPageFilter filter) async {
    final rawData = await _dapaWallet.history(filter: filter);
    return rawData
        .map((e) => jsonDecode(e))
        .map(
          (entry) =>
              sdk.TransactionEntry.fromJson(entry as Map<String, dynamic>),
        )
        .toList();
  }

  Future<sdk.GetInfoResult> getDaemonInfo() async {
    final rawData = await _dapaWallet.getDaemonInfo();
    final json = jsonDecode(rawData);
    return sdk.GetInfoResult.fromJson(json as Map<String, dynamic>);
  }

  Future<void> rescan({required int topoheight}) async {
    return _dapaWallet.rescan(topoheight: BigInt.from(topoheight));
  }

  Future<String> estimateFees(
    List<Transfer> transfers,
    double? feeMultiplier,
  ) async {
    return _dapaWallet.estimateFees(
      transfers: transfers,
      feeMultiplier: feeMultiplier,
    );
  }

  Future<TransactionSummary> createTransferTransaction({
    double? amount,
    required String address,
    required String assetHash,
    double? feeMultiplier,
  }) async {
    String rawTx;
    if (amount != null) {
      rawTx = await _dapaWallet.createTransfersTransaction(
        transfers: [
          Transfer(
            floatAmount: amount,
            strAddress: address,
            assetHash: assetHash,
          ),
        ],
        feeMultiplier: feeMultiplier,
      );
    } else {
      rawTx = await _dapaWallet.createTransferAllTransaction(
        strAddress: address,
        assetHash: assetHash,
        feeMultiplier: feeMultiplier,
      );
    }
    final jsonTx = jsonDecode(rawTx) as Map<String, dynamic>;
    return TransactionSummary.fromJson(jsonTx);
  }

  Future<String> createMultisigTransferTransaction({
    double? amount,
    required String address,
    required String assetHash,
    double? feeMultiplier,
  }) async {
    if (amount != null) {
      return _dapaWallet.createMultisigTransfersTransaction(
        transfers: [
          Transfer(
            floatAmount: amount,
            strAddress: address,
            assetHash: assetHash,
          ),
        ],
        feeMultiplier: feeMultiplier,
      );
    } else {
      return _dapaWallet.createMultisigTransferAllTransaction(
        strAddress: address,
        assetHash: assetHash,
        feeMultiplier: feeMultiplier,
      );
    }
  }

  Future<TransactionSummary> createTransfersTransaction(
    List<Transfer> transfers,
  ) async {
    final rawTx = await _dapaWallet.createTransfersTransaction(
      transfers: transfers,
    );
    final jsonTx = jsonDecode(rawTx) as Map<String, dynamic>;
    return TransactionSummary.fromJson(jsonTx);
  }

  Future<String> createMultisigTransfersTransaction(
    List<Transfer> transfers,
  ) async {
    return _dapaWallet.createMultisigTransfersTransaction(
      transfers: transfers,
    );
  }

  Future<TransactionSummary> createBurnTransaction({
    double? amount,
    required String assetHash,
  }) async {
    String rawTx;
    if (amount == null) {
      rawTx = await _dapaWallet.createBurnAllTransaction(assetHash: assetHash);
    } else {
      rawTx = await _dapaWallet.createBurnTransaction(
        floatAmount: amount,
        assetHash: assetHash,
      );
    }
    final jsonTx = jsonDecode(rawTx) as Map<String, dynamic>;
    return TransactionSummary.fromJson(jsonTx);
  }

  Future<String> createMultisigBurnTransaction({
    double? amount,
    required String assetHash,
  }) async {
    if (amount == null) {
      return await _dapaWallet.createMultisigBurnAllTransaction(
        assetHash: assetHash,
      );
    } else {
      return await _dapaWallet.createMultisigBurnTransaction(
        floatAmount: amount,
        assetHash: assetHash,
      );
    }
  }

  Future<void> broadcastTransaction(String hash) async {
    await _dapaWallet.broadcastTransaction(txHash: hash);
    talker.info('Transaction successfully broadcast: $hash');
  }

  Future<void> clearTransaction(String hash) async {
    await _dapaWallet.clearTransaction(txHash: hash);
    talker.info('Transaction canceled: $hash');
  }

  Future<MultisigState?> getMultisigState() async {
    final rawData = await _dapaWallet.getMultisigState();
    switch (rawData) {
      case String():
        final json = jsonDecode(rawData) as Map<String, dynamic>;
        return MultisigState.fromJson(json);
      case null:
        return null;
    }
  }

  Future<String> signTransactionHash(String txHash) async {
    return _dapaWallet.multisigSign(txHash: txHash);
  }

  Future<TransactionSummary?> setupMultisig({
    required List<String> participants,
    required int threshold,
  }) async {
    final rawTx = await _dapaWallet.multisigSetup(
      threshold: threshold,
      participants: participants,
    );
    final jsonTx = jsonDecode(rawTx) as Map<String, dynamic>;
    return TransactionSummary.fromJson(jsonTx);
  }

  bool isAddressValidForMultisig(String address) {
    return _dapaWallet.isAddressValidForMultisig(address: address);
  }

  Future<String> initDeleteMultisig() async {
    return _dapaWallet.initDeleteMultisig();
  }

  Future<TransactionSummary?> finalizeMultisigTransaction({
    required List<SignatureMultisig> signatures,
  }) async {
    final rawTx = await _dapaWallet.finalizeMultisigTransaction(
      signatures: signatures,
    );
    final jsonTx = jsonDecode(rawTx) as Map<String, dynamic>;
    return TransactionSummary.fromJson(jsonTx);
  }

  Future<void> startXSWD({
    required Future<void> Function(XswdRequestSummary) cancelRequestCallback,
    required Future<UserPermissionDecision> Function(XswdRequestSummary)
    requestApplicationCallback,
    required Future<UserPermissionDecision> Function(XswdRequestSummary)
    requestPermissionCallback,
    required Future<void> Function(XswdRequestSummary) appDisconnectCallback,
  }) async {
    if (await _dapaWallet.isXswdRunning()) {
      talker.warning('XSWD already running...');
      return;
    }
    _dapaWallet.startXswd(
      cancelRequestDartCallback: cancelRequestCallback,
      requestApplicationDartCallback: requestApplicationCallback,
      requestPermissionDartCallback: requestPermissionCallback,
      appDisconnectDartCallback: appDisconnectCallback,
    );
  }

  Future<void> stopXSWD() async {
    if (!await _dapaWallet.isXswdRunning()) {
      talker.warning('XSWD already stopped...');
      return;
    }
    _dapaWallet.stopXswd();
  }

  Future<List<AppInfo>> getXswdState() async {
    if (!await _dapaWallet.isXswdRunning()) {
      talker.info('XSWD state not available, XSWD is not running');
      return [];
    }
    return _dapaWallet.getApplicationPermissions();
  }

  Future<void> removeXswdApp(String appID) async {
    await _dapaWallet.closeApplicationSession(id: appID);
  }

  Future<void> modifyXSWDAppPermissions(
    String appID,
    Map<String, PermissionPolicy> permissions,
  ) async {
    await _dapaWallet.modifyApplicationPermissions(
      id: appID,
      permissions: permissions,
    );
  }

  Future<AddressBookData> retrieveAllContacts() async {
    return _dapaWallet.retrieveAllContacts();
  }

  Future<void> upsertContact({
    required String name,
    required String address,
    String? note,
  }) async {
    await _dapaWallet.upsertContact(
      entry: ContactDetails(name: name, address: address, note: note),
    );
  }

  Future<void> removeContact(String address) async {
    await _dapaWallet.removeContact(address: address);
  }

  Future<bool> isContactPresent(String address) async {
    final isPresent = await _dapaWallet.isContactPresent(address: address);
    return isPresent;
  }

  Future<ContactDetails> getContact(String address) async {
    final contact = await _dapaWallet.findContactByAddress(address: address);
    return contact;
  }

  Future<AddressBookData> findContactsByName(String name) async {
    final contacts = await _dapaWallet.findContactsByName(name: name);
    return contacts;
  }

  Future<void> exportTransactionsToCsvFile(String path) async {
    await _dapaWallet.exportTransactionsToCsvFile(filePath: path);
  }

  Future<String> convertTransactionsToCsv() async {
    return _dapaWallet.convertTransactionsToCsv();
  }
}
