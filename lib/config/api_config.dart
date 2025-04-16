import 'package:http/http.dart' as http;

class ApiConfig {
  // Base URLs for different environments
  static const String _productionUrl = 'https://meditrack-api-b1nm.onrender.com/api';
  static const String _rootUrl = 'https://meditrack-api-b1nm.onrender.com';
  
  // Get the appropriate base URL based on platform and environment
  static String get baseUrl {
    // Always use the production URL
    return _productionUrl;
  }
  
  static String get rootUrl {
    return _rootUrl;
  }
  
  // Request timeout duration
  static const Duration timeout = Duration(seconds: 30);
  
  // Auth endpoints
  static String get login => '$baseUrl/users/login';
  static String get register => '$baseUrl/users/register';
  static String get getUser => '$baseUrl/users/getUser';
  
  // Patient endpoints
  static String get patients => '$baseUrl/patients';
  static String get criticalPatients => '$baseUrl/patients/critical';
  
  // Test endpoints
  static String get tests => '$baseUrl/tests';
  static String get criticalTests => '$baseUrl/tests/critical';
  
  // Check if the API is available
  static Future<bool> checkApiAvailability() async {
    print('Checking API availability at $rootUrl...');
    try {
      // First try with a short timeout
      final response = await http.get(Uri.parse(rootUrl)).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('API availability check timed out (short timeout)');
          throw Exception('Timeout');
        },
      );
      
      print('API availability check response: ${response.statusCode}');
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (e) {
      print('API availability check failed with short timeout: $e');
      
      // Try again with a longer timeout
      try {
        final response = await http.get(Uri.parse(rootUrl)).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('API availability check timed out (long timeout)');
            return http.Response('Timeout', 408);
          },
        );
        
        print('API availability check response (long timeout): ${response.statusCode}');
        return response.statusCode >= 200 && response.statusCode < 500;
      } catch (e) {
        print('API availability check failed with long timeout: $e');
        return false;
      }
    }
  }
}
