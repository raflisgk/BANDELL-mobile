class ApiService {
  /// Base URL endpoint Laravel backend API
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  /// Token session untuk autentikasi Bearer Token
  static String? _authToken;

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static String? get authToken => _authToken;

  /// Default headers yang akan dikirim pada setiap request API
  static Map<String, String> get defaultHeaders => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  /// Headers untuk upload multipart (file/foto)
  static Map<String, String> get multipartHeaders => {
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
}
