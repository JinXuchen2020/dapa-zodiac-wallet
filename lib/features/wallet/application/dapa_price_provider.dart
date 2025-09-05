import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zodiac/features/wallet/domain/dapa_price/coinpaprika/dapa_ticker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:http/http.dart' as http;

part 'dapa_price_provider.g.dart';

final Uri coinPaprikaEndpoint = Uri.https(
  'api.coinpaprika.com',
  '/v1/tickers/dap-dapa',
);

@riverpod
Future<DapaTicker> dapaPrice(Ref ref) async {
  final timer = Timer(const Duration(seconds: 60), () => ref.invalidateSelf());
  final client = http.Client();

  ref.onDispose(() {
    timer.cancel();
    client.close();
  });

  final response = await client.get(coinPaprikaEndpoint);

  ref.keepAlive();

  final json = jsonDecode(response.body) as Map<String, dynamic>;
  return DapaTicker.fromJson(json);
}
