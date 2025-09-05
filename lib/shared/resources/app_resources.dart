import 'package:country_flags/country_flags.dart';
import 'package:flutter/widgets.dart';
import 'package:zodiac/features/wallet/domain/node_address.dart';
import 'package:zodiac/src/generated/l10n/app_localizations.dart';
import 'package:xelis_dart_sdk/xelis_dart_sdk.dart' as sdk;
// import 'package:jovial_svg/jovial_svg.dart';

class AppResources {
  static const String dapaWalletName = 'Zodiac';

  static const String userWalletsFolderName = 'Zodiac wallets';

  static const String zeroBalance = '0.00000000';

  static const String dapaHash = '0000000000000000000000000000000000000000000000000000000000000000';

  static const String dapaName = 'DAPA';

  static const int dapaDecimals = 8;

  static List<NodeAddress> mainnetNodes = [
    // const NodeAddress(
    //   name: 'Official Seed Node #1',
    //   url: 'https://${sdk.mainnetNodeURL}',
    // ),
    const NodeAddress(
      name: 'Seed Node #1',
      url: 'https://node.dapahe.com/',
    ),
    
  ];

  static List<NodeAddress> testnetNodes = [
    const NodeAddress(
      name: 'Official DAPA Testnet',
      url: 'https://${sdk.testnetNodeURL}',
    ),
  ];

  static List<NodeAddress> devNodes = [
    const NodeAddress(
      name: 'Default Local Node',
      url: 'http://${sdk.localhostAddress}',
    ),
    const NodeAddress(
      name: 'Android simulator localhost',
      url: 'http://10.0.2.2:8080',
    ),
  ];

  static String explorerMainnetUrl = 'https://explorer.dapahe.com/';
  static String explorerTestnetUrl = 'https://testnet-explorer.dapahe.com/';

  /*static String svgIconGreenTarget =
      'https://raw.githubusercontent.com/k7n2g/dapa-assets/master/icons/svg/transparent/green.svg';
  static String svgIconBlackTarget =
      'https://raw.githubusercontent.com/k7n2g/dapa-assets/master/icons/svg/transparent/black.svg';
  static String svgIconWhiteTarget =
      'https://raw.githubusercontent.com/k7n2g/dapa-assets/master/icons/svg/transparent/white.svg';

  static late ScalableImage svgIconGreen;
  static late ScalableImage svgIconWhite;
  static late ScalableImage svgIconBlack;

  static ScalableImageWidget svgIconGreenWidget = ScalableImageWidget(
    si: AppResources.svgIconGreen,
    scale: 0.06,
  );

  static ScalableImageWidget svgIconBlackWidget = ScalableImageWidget(
    si: AppResources.svgIconBlack,
    scale: 0.06,
  );

  static ScalableImageWidget svgIconWhiteWidget = ScalableImageWidget(
    si: AppResources.svgIconWhite,
    scale: 0.06,
  );*/

  // static String svgBannerGreenPath =
  //     'assets/banners/svg/transparent_background_green_logo.svg';
  // static String svgBannerBlackPath =
  //     'assets/banners/svg/transparent_background_black_logo.svg';
  // static String svgBannerWhitePath =
  //     'assets/banners/svg/transparent_background_white_logo.svg';
  static const String greenBackgroundBlackIconPath =
      'assets/icons/png/circle/black_background_green_logo.png';
  static const String bgDotsPath = 'assets/bg_dots.png';

  // static late ScalableImage svgBannerGreen;
  // static late ScalableImage svgBannerWhite;
  // static late ScalableImage svgBannerBlack;
  static late Image bgDots;

  // static ScalableImageWidget svgBannerGreenWidget = ScalableImageWidget(
  //   si: AppResources.svgBannerGreen,
  //   scale: 0.15,
  // );
  //
  // static ScalableImageWidget svgBannerBlackWidget = ScalableImageWidget(
  //   si: AppResources.svgBannerBlack,
  //   scale: 0.15,
  // );
  //
  // static ScalableImageWidget svgBannerWhiteWidget = ScalableImageWidget(
  //   si: AppResources.svgBannerWhite,
  //   scale: 0.15,
  // );

  static List<CountryFlag> countryFlags = List.generate(
    AppLocalizations.supportedLocales.length,
    (int index) {
      String languageCode =
          AppLocalizations.supportedLocales[index].languageCode;
      switch (languageCode) {
        case 'zh':
          return CountryFlag.fromCountryCode(
            'CN',
            height: 24,
            width: 30,
            shape: const RoundedRectangle(8),
          );
        case 'ru' || 'pt' || 'nl' || 'pl':
          return CountryFlag.fromCountryCode(
            languageCode,
            height: 24,
            width: 30,
            shape: const RoundedRectangle(8),
          );
        case 'ko':
          return CountryFlag.fromCountryCode(
            'KR',
            height: 24,
            width: 30,
            shape: const RoundedRectangle(8),
          );
        case 'ms':
          return CountryFlag.fromCountryCode(
            'MY',
            height: 24,
            width: 30,
            shape: const RoundedRectangle(8),
          );
        case 'uk':
          return CountryFlag.fromCountryCode(
            'UA',
            height: 24,
            width: 30,
            shape: const RoundedRectangle(8),
          );
        case 'ja':
          return CountryFlag.fromCountryCode(
            'JP',
            height: 24,
            width: 30,
            shape: const RoundedRectangle(8),
          );
        case 'ar':
          return CountryFlag.fromCountryCode(
            'SA',
            height: 24,
            width: 30,
            shape: const RoundedRectangle(8),
          );
        default:
          return CountryFlag.fromLanguageCode(
            AppLocalizations.supportedLocales[index].languageCode,
            height: 24,
            width: 30,
            shape: const RoundedRectangle(8),
          );
      }
    },
    growable: false,
  );
}
