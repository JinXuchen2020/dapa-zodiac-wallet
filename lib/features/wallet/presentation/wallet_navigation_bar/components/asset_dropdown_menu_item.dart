import 'package:flutter/material.dart';
import 'package:zodiac/features/wallet/presentation/wallet_navigation_bar/components/logo.dart';
import 'package:zodiac/shared/resources/app_resources.dart';
import 'package:zodiac/shared/theme/constants.dart';
import 'package:zodiac/shared/utils/utils.dart';
import 'package:xelis_dart_sdk/xelis_dart_sdk.dart';

class AssetDropdownMenuItem {
  static DropdownMenuItem<String> fromMapEntry(
    MapEntry<String, String> balanceEntry,
    AssetData assetData, {
    bool showBalance = true,
  }) {
    final isDapaAsset = balanceEntry.key == AppResources.dapaHash;
    final dapaImagePath = AppResources.greenBackgroundBlackIconPath;

    final assetName = assetData.name;
    final assetTicker = assetData.ticker;

    return DropdownMenuItem<String>(
      value: balanceEntry.key,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isDapaAsset
              ? Row(
                  children: [
                    Logo(imagePath: dapaImagePath),
                    const SizedBox(width: Spaces.small),
                    Text(assetName),
                  ],
                )
              : Text(truncateText(assetName)),
          if (showBalance) Text('${balanceEntry.value} $assetTicker'),
        ],
      ),
    );
  }
}
