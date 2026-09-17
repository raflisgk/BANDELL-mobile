import 'package:flutter_test/flutter_test.dart';

bool isLatitudeValid(String latStr) {
  final text = latStr.replaceAll(',', '.').trim();
  if (text.isEmpty) return false;
  final lat = double.tryParse(text);
  if (lat == null) return false;
  return lat >= -90.0 && lat <= 90.0;
}

bool isLongitudeValid(String lngStr) {
  final text = lngStr.replaceAll(',', '.').trim();
  if (text.isEmpty) return false;
  final lng = double.tryParse(text);
  if (lng == null) return false;
  return lng >= -180.0 && lng <= 180.0;
}

bool isValidCoordinate(String latStr, String lngStr) {
  return isLatitudeValid(latStr) && isLongitudeValid(lngStr);
}

void main() {
  group('Coordinate Validation Tests', () {
    test('Valid standard coordinates', () {
      expect(isValidCoordinate('-6.2088', '106.8456'), isTrue);
      expect(isValidCoordinate('0.0', '0.0'), isTrue);
      expect(isValidCoordinate(' -6.2088 ', ' 106.8456 '), isTrue);
    });

    test('Valid comma coordinates (Indonesian keyboard locale)', () {
      expect(isValidCoordinate('-6,2088', '106,8456'), isTrue);
    });

    test('Valid boundary coordinates', () {
      expect(isLatitudeValid('-90'), isTrue);
      expect(isLatitudeValid('90'), isTrue);
      expect(isLatitudeValid('-90.000000'), isTrue);
      expect(isLatitudeValid('90.000000'), isTrue);

      expect(isLongitudeValid('-180'), isTrue);
      expect(isLongitudeValid('180'), isTrue);
      expect(isLongitudeValid('-180.000000'), isTrue);
      expect(isLongitudeValid('180.000000'), isTrue);
    });

    test('Invalid out-of-range coordinates', () {
      expect(isLatitudeValid('-90.000001'), isFalse);
      expect(isLatitudeValid('90.000001'), isFalse);
      expect(isLatitudeValid('999'), isFalse);
      expect(isLatitudeValid('-100'), isFalse);

      expect(isLongitudeValid('-180.000001'), isFalse);
      expect(isLongitudeValid('180.000001'), isFalse);
      expect(isLongitudeValid('200'), isFalse);
      expect(isLongitudeValid('-250'), isFalse);
    });

    test('Empty or non-numeric strings', () {
      expect(isValidCoordinate('', '106.8456'), isFalse);
      expect(isValidCoordinate('-6.2088', ''), isFalse);
      expect(isValidCoordinate('', ''), isFalse);
      expect(isValidCoordinate('abc', '106.8456'), isFalse);
      expect(isValidCoordinate('-6.2088', 'xyz'), isFalse);
      expect(isValidCoordinate('--', '..'), isFalse);
    });
  });
}

