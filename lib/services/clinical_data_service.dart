import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/clinical_data.dart';
import 'auth_service.dart';
import 'patient_service.dart';

class ClinicalDataService {
  // Get all tests for a patient
  static Future<Map<String, dynamic>> getTestsByPatientId(
      String patientId) async {
    try {
      // First check if user is logged in
      final token = await AuthService.getUserToken();

      if (token == null) {
        print('ClinicalDataService: User not logged in');
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      print('ClinicalDataService: Fetching tests for patient: $patientId');
      print(
          'ClinicalDataService: Using token: ${token.substring(0, min(10, token.length))}...');

      // Check if API is available before making the request
      final isApiAvailable = await ApiConfig.checkApiAvailability();
      if (!isApiAvailable) {
        print(
            'ClinicalDataService: API not available, sending wake-up request');
        try {
          // Try to wake up the server
          await http.get(Uri.parse(ApiConfig.baseUrl)).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('ClinicalDataService: Wake-up request timed out');
              throw Exception('Server wake-up timed out');
            },
          );
          // Wait a bit for the server to wake up
          await Future.delayed(const Duration(seconds: 2));
        } catch (e) {
          print('ClinicalDataService: Wake-up request failed: $e');
          // Continue anyway, the server might be waking up
        }
      }

      // Now make the actual request
      final response = await http.get(
        Uri.parse('${ApiConfig.tests}/$patientId/tests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      print(
          'ClinicalDataService: Response status code: ${response.statusCode}');
      print(
          'ClinicalDataService: Response body length: ${response.body.length}');
      print(
          'ClinicalDataService: Response body preview: ${response.body.substring(0, min(100, response.body.length))}...');

      // Try to parse the response body
      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        print('ClinicalDataService: Error parsing response JSON: $e');
        return {
          'success': false,
          'message': 'Invalid response format: ${e.toString()}',
        };
      }

      if (response.statusCode == 200) {
        // Handle different response formats
        List<dynamic> testsJson = [];
        if (responseData is List) {
          // If the response is directly a list
          testsJson = responseData;
        } else if (responseData is Map &&
            responseData['data'] != null &&
            responseData['data'] is List) {
          // If the response has a data field with a list
          testsJson = responseData['data'] as List<dynamic>;
        } else if (responseData is Map) {
          // Try to find any list in the response
          responseData.forEach((key, value) {
            if (value is List) {
              testsJson = value;
            }
          });
        }

        // Parse the clinical data objects
        final List<ClinicalData> tests = [];
        for (var json in testsJson) {
          try {
            tests.add(ClinicalData.fromJson(json));
          } catch (e) {
            print('ClinicalDataService: Error parsing clinical data: $e');
            print('ClinicalDataService: Problematic JSON: $json');
            // Continue with the next item
          }
        }

        print('ClinicalDataService: Parsed ${tests.length} tests');

        return {
          'success': true,
          'message': 'Tests retrieved successfully',
          'data': tests
        };
      } else {
        final message = responseData is Map
            ? responseData['message']
            : 'Failed to get tests';
        print('ClinicalDataService: Error response: $message');
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      print('ClinicalDataService: Error fetching tests: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get critical tests
  static Future<Map<String, dynamic>> getCriticalTests() async {
    try {
      final token = await AuthService.getUserToken();

      if (token == null) {
        print('ClinicalDataService: User not logged in');
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      print('ClinicalDataService: Fetching critical tests');

      final response = await http.get(
        Uri.parse(ApiConfig.criticalTests),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      print(
          'ClinicalDataService: Critical response status: ${response.statusCode}');
      print(
          'ClinicalDataService: Response body preview: ${response.body.substring(0, min(100, response.body.length))}...');

      // Try to parse the response body
      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        print('ClinicalDataService: Error parsing response JSON: $e');
        return {
          'success': false,
          'message': 'Invalid response format: ${e.toString()}',
        };
      }

      if (response.statusCode == 200) {
        // Handle different response formats
        List<dynamic> testsJson = [];
        if (responseData is List) {
          // If the response is directly a list
          testsJson = responseData;
        } else if (responseData is Map &&
            responseData['data'] != null &&
            responseData['data'] is List) {
          // If the response has a data field with a list
          testsJson = responseData['data'] as List<dynamic>;
        } else if (responseData is Map) {
          // Try to find any list in the response
          responseData.forEach((key, value) {
            if (value is List) {
              testsJson = value;
            }
          });
        }

        // Parse the clinical data objects
        final List<ClinicalData> tests = [];
        for (var json in testsJson) {
          try {
            tests.add(ClinicalData.fromJson(json));
          } catch (e) {
            print('ClinicalDataService: Error parsing critical test: $e');
            // Continue with the next item
          }
        }

        print('ClinicalDataService: Parsed ${tests.length} critical tests');

        return {
          'success': true,
          'message': 'Critical tests retrieved successfully',
          'data': tests
        };
      } else {
        final message = responseData is Map
            ? responseData['message']
            : 'Failed to get critical tests';
        print('ClinicalDataService: Error response: $message');
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      print('ClinicalDataService: Error fetching critical tests: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get test by ID
  static Future<Map<String, dynamic>> getTestById(String testId) async {
    try {
      final token = await AuthService.getUserToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.tests}/$testId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      print(
          'ClinicalDataService: Get test by ID response status: ${response.statusCode}');

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        print('ClinicalDataService: Error parsing response JSON: $e');
        return {
          'success': false,
          'message': 'Invalid response format: ${e.toString()}',
        };
      }

      if (response.statusCode == 200) {
        dynamic testJson;
        if (responseData is Map) {
          testJson = responseData['data'] ?? responseData;
        } else {
          testJson = responseData;
        }
        final test = ClinicalData.fromJson(testJson);

        return {
          'success': true,
          'message': 'Test retrieved successfully',
          'data': test
        };
      } else {
        final message = responseData is Map
            ? responseData['message']
            : 'Failed to get test';
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      print('ClinicalDataService: Error fetching test by ID: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Add a new test
  static Future<Map<String, dynamic>> addTest(
      String patientId, ClinicalData test) async {
    try {
      final token = await AuthService.getUserToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      print('ClinicalDataService: Adding test for patient: $patientId');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.tests}/$patientId/tests'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(test.toJson()),
          )
          .timeout(ApiConfig.timeout);

      print(
          'ClinicalDataService: Add test response status: ${response.statusCode}');

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        print('ClinicalDataService: Error parsing response JSON: $e');
        return {
          'success': false,
          'message': 'Invalid response format: ${e.toString()}',
        };
      }

      if (response.statusCode == 201) {
        dynamic testJson;
        if (responseData is Map) {
          testJson = responseData['data'] ?? responseData;
        } else {
          testJson = responseData;
        }
        final createdTest = ClinicalData.fromJson(testJson);

        // Update patient status based on whether the test is critical
        await _updatePatientStatusBasedOnTest(patientId, test.criticalFlag);

        return {
          'success': true,
          'message': 'Status updated successfully',
          'data': createdTest
        };
      } else {
        final message = responseData is Map
            ? responseData['message']
            : 'Failed to add test';
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      print('ClinicalDataService: Error adding test: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Update test
  static Future<Map<String, dynamic>> updateTest(
      String testId, Map<String, dynamic> data) async {
    try {
      // Check API availability
      final bool isApiAvailable = await ApiConfig.checkApiAvailability();
      if (!isApiAvailable) {
        return {
          'success': false,
          'message': 'Server is not available. Please try again later.',
        };
      }

      // Get the token
      final token = await AuthService.getUserToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token not found. Please login again.',
        };
      }

      print('ClinicalDataService: Updating test with ID: $testId');
      print('ClinicalDataService: Update data: $data');

      // Make the API call
      final response = await http.put(
        Uri.parse('${ApiConfig.tests}/$testId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'dataType': data['dataType'],
          'reading': data['reading'],
          'testDate': data['testDate'],
        }),
      );

      print(
          'ClinicalDataService: Update response status: ${response.statusCode}');
      print('ClinicalDataService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final updatedTest = ClinicalData.fromJson(responseData);

        // Update patient status based on whether the test is critical
        await _updatePatientStatusBasedOnTest(
            updatedTest.patientId, updatedTest.criticalFlag);

        return {
          'success': true,
          'data': updatedTest,
          'message': 'Test updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update test. Please try again.',
        };
      }
    } catch (e) {
      print('ClinicalDataService: Error updating test: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Helper method to update patient status based on test criticality
  static Future<void> _updatePatientStatusBasedOnTest(
      String patientId, bool isCritical) async {
    try {
      // Determine the new status based on whether the test is critical
      final String newStatus = isCritical ? 'Critical' : 'Stable';

      print(
          'ClinicalDataService: Updating patient status to $newStatus based on test criticality');

      // Call the updatePatientStatus method from PatientService
      final result =
          await PatientService.updatePatientStatus(patientId, newStatus);

      if (result['success']) {
        print(
            'ClinicalDataService: SUCCESS - Patient status updated to $newStatus');
        print('ClinicalDataService: Patient ID: $patientId');
        print('ClinicalDataService: API Response: ${result['message']}');

        // If the result contains the updated patient data, print some details
        if (result['data'] != null) {
          print('ClinicalDataService: Updated patient data received');
        }
      } else {
        print(
            'ClinicalDataService: FAILED to update patient status: ${result['message']}');
      }
    } catch (e) {
      print('ClinicalDataService: Error updating patient status: $e');
    }
  }

  // Delete test
  static Future<Map<String, dynamic>> deleteTest(String testId) async {
    try {
      final token = await AuthService.getUserToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.tests}/$testId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      dynamic responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        print('ClinicalDataService: Error parsing response JSON: $e');
        return {
          'success': false,
          'message': 'Invalid response format: ${e.toString()}',
        };
      }

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Test deleted successfully',
        };
      } else {
        final message = responseData is Map
            ? responseData['message']
            : 'Failed to delete test';
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      print('ClinicalDataService: Error deleting test: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
