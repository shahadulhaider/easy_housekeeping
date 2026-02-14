class AppConstants {
  AppConstants._();

  static const String appName = 'EasyHousekeeping';
  static const String currencySymbol = '৳';
  static const String currencyCode = 'BDT';
  static const int defaultHeadcountBaseline = 6;
  static const double emaAlpha = 0.3;
  static const int lowStockWarningDays = 3;
  static const int warrantyWarningDays = 30;
  static const String openFoodFactsBaseUrl =
      'https://world.openfoodfacts.org/api/v2/product';
}
