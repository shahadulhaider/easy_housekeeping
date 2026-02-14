import 'package:dio/dio.dart';

/// Result model for barcode lookups from Open Food Facts.
class BarcodeResult {
  final String productName;
  final String? brand;
  final String? categoryHint;
  final String? imageUrl;

  const BarcodeResult({
    required this.productName,
    this.brand,
    this.categoryHint,
    this.imageUrl,
  });
}

/// Looks up product information by barcode using the Open Food Facts API.
class BarcodeService {
  final Dio _dio;

  BarcodeService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  /// Queries Open Food Facts for the given [barcode].
  /// Returns a [BarcodeResult] on success, or `null` if the product is not
  /// found or the request fails.
  Future<BarcodeResult?> lookupBarcode(String barcode) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://world.openfoodfacts.org/api/v2/product/$barcode.json',
      );

      final data = response.data;
      if (data == null || data['status'] != 1) return null;

      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      final productName =
          product['product_name'] as String? ??
          product['product_name_en'] as String?;
      if (productName == null || productName.isEmpty) return null;

      return BarcodeResult(
        productName: productName,
        brand: product['brands'] as String?,
        categoryHint: product['categories'] as String?,
        imageUrl: product['image_front_url'] as String?,
      );
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
