/// Utility class for centralized data validations
class Validators {
  /// Validates if a latitude string is within valid range [-90.0, 90.0]
  static bool isLatitudeValid(String latStr) {
    final text = latStr.replaceAll(',', '.').trim();
    if (text.isEmpty) return false;
    final lat = double.tryParse(text);
    if (lat == null) return false;
    return lat >= -90.0 && lat <= 90.0;
  }

  /// Validates if a longitude string is within valid range [-180.0, 180.0]
  static bool isLongitudeValid(String lngStr) {
    final text = lngStr.replaceAll(',', '.').trim();
    if (text.isEmpty) return false;
    final lng = double.tryParse(text);
    if (lng == null) return false;
    return lng >= -180.0 && lng <= 180.0;
  }

  /// Validates both latitude and longitude
  static bool isValidCoordinate(String latStr, String lngStr) {
    return isLatitudeValid(latStr) && isLongitudeValid(lngStr);
  }
}
