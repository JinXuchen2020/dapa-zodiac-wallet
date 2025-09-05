// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zodiac/features/wallet/domain/dapa_price/coinpaprika/quotes.dart';

part 'dapa_ticker.freezed.dart';

part 'dapa_ticker.g.dart';

@freezed
abstract class DapaTicker with _$DapaTicker {
  const DapaTicker._();

  const factory DapaTicker({
    required String id,
    required String name,
    required String symbol,
    required int rank,
    @JsonKey(name: 'total_supply') required int totalSupply,
    @JsonKey(name: 'max_supply') required int maxSupply,
    @JsonKey(name: 'beta_value') required double betaValue,
    @JsonKey(name: 'first_data_at') required DateTime firstDataAt,
    @JsonKey(name: 'last_updated') required DateTime lastUpdated,
    required Quotes quotes,
  }) = _DapaTicker;

  factory DapaTicker.fromJson(Map<String, dynamic> json) =>
      _$DapaTickerFromJson(json);

  double get price => quotes.usd.price;
}
