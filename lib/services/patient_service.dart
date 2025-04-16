import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/patient.dart';
import 'auth_service.dart';

class PatientService {
  // Alias for getAllPatients
  static Future<Map<String, dynamic>> getPatients() async => getAllPatients();

  // Get all patients
  static Future<Map<String, dynamic>> getAllPatients() async {
    try {
      final token = await AuthService.getUserToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      print('Fetching patients from: ${ApiConfig.patients}');
      print('Using token: ${token.substring(0, 10)}...');

      final response = await http.get(
        Uri.parse(ApiConfig.patients),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      print('Response status code: ${response.statusCode}');
      print(
          'Response body: ${response.body.substring(0, min(100, response.body.length))}...');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> patientsJson = responseData ?? [];
        final List<Patient> patients =
            patientsJson.map((json) => Patient.fromJson(json)).toList();

        print('Parsed ${patients.length} patients');

        return {
          'success': true,
          'message': 'Patients retrieved successfully',
          'data': patients
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get patients',
        };
      }
    } catch (e) {
      print('Error fetching patients: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get critical patients
  static Future<Map<String, dynamic>> getCriticalPatients() async {
    try {
      final token = await AuthService.getUserToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      print('Fetching critical patients from: ${ApiConfig.criticalPatients}');

      final response = await http.get(
        Uri.parse(ApiConfig.criticalPatients),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(ApiConfig.timeout);

      print('Critical response status: ${response.statusCode}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> patientsJson = responseData ?? [];
        final List<Patient> patients =
            patientsJson.map((json) => Patient.fromJson(json)).toList();

        print('Parsed ${patients.length} critical patients');

        return {
          'success': true,
          'message': 'Critical patients retrieved successfully',
          'data': patients
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Failed to get critical patients',
        };
      }
    } catch (e) {
      print('Error fetching critical patients: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Get patient by ID
  static Future<Map<String, dynamic>> getPatientById(String patientId) async {
    try {
      final token = await AuthService.getUserToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.patients}/$patientId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final patientJson = responseData['data'];
        final patient = Patient.fromJson(patientJson);

        return {
          'success': true,
          'message': 'Patient retrieved successfully',
          'data': patient
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get patient',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Add a new patient
  static Future<Map<String, dynamic>> addPatient(Patient patient) async {
    try {
      final token = await AuthService.getUserToken();

      if (token == null) {
        print('PatientService: No token found');
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      print(
          'PatientService: Adding patient with data: ${jsonEncode(patient.toJson())}');
      print('PatientService: Using endpoint: ${ApiConfig.patients}');

      final response = await http.post(
        Uri.parse(ApiConfig.patients),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(patient.toJson()),
      );

      print('PatientService: Response status code: ${response.statusCode}');
      print('PatientService: Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      // Accept both 200 and 201 as success status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle different response formats
        Map<String, dynamic> patientJson;
        if (responseData is Map<String, dynamic>) {
          // If the response is the patient object directly
          patientJson = responseData;
        } else {
          // If there's a nested data field
          patientJson =
              (responseData['data'] ?? responseData) as Map<String, dynamic>;
        }

        try {
          final createdPatient = Patient.fromJson(patientJson);
          print(
              'PatientService: Successfully created patient with ID: ${createdPatient.id}');
          return {
            'success': true,
            'message': 'Patient added successfully',
            'data': createdPatient
          };
        } catch (e) {
          print('PatientService: Error parsing created patient: $e');
          // Even if we can't parse the response, consider it a success if the server accepted it
          return {
            'success': true,
            'message': 'Patient added successfully',
            'data': patient
          };
        }
      } else {
        print(
            'PatientService: Failed to add patient. Status: ${response.statusCode}, Message: ${responseData['message']}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to add patient',
        };
      }
    } catch (e) {
      print('PatientService: Error adding patient: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Update patient
  static Future<Map<String, dynamic>> updatePatient(
      String patientId, Patient patient) async {
    try {
      final token = await AuthService.getUserToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      print('Updating patient with ID: $patientId');
      print('Update data: ${jsonEncode(patient.toJson())}');

      final response = await http.put(
        Uri.parse('${ApiConfig.patients}/$patientId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(patient.toJson()),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);

          // Handle different response formats
          Map<String, dynamic> patientJson;
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('data')) {
              patientJson = responseData['data'];
            } else {
              patientJson = responseData;
            }
          } else {
            return {
              'success': true,
              'message': 'Patient updated successfully',
              'data':
                  patient // Return the original patient if response format is unexpected
            };
          }

          final updatedPatient = Patient.fromJson(patientJson);

          return {
            'success': true,
            'message': 'Patient updated successfully',
            'data': updatedPatient
          };
        } catch (e) {
          print('Error parsing update response: $e');
          // Even if parsing fails, consider it a success if server returned 200
          return {
            'success': true,
            'message': 'Patient updated successfully',
            'data': patient
          };
        }
      } else {
        String message;
        try {
          final responseData = jsonDecode(response.body);
          message = responseData['message'] ?? 'Failed to update patient';
        } catch (e) {
          message = 'Failed to update patient';
        }
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      print('Error updating patient: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Delete patient
  static Future<Map<String, dynamic>> deletePatient(String patientId) async {
    try {
      final token = await AuthService.getUserToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.patients}/$patientId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Patient deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete patient',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Update patient status
  static Future<Map<String, dynamic>> updatePatientStatus(
      String patientId, String status) async {
    try {
      final token = await AuthService.getUserToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'User not logged in',
        };
      }

      print('Updating patient status with ID: $patientId to status: $status');

      final response = await http.put(
        Uri.parse('${ApiConfig.patients}/update-status/$patientId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );

      print('Update status response: ${response.statusCode}');
      print('Update status response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);

          // Handle different response formats
          Map<String, dynamic> patientJson;
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('data')) {
              patientJson = responseData['data'];
            } else {
              patientJson = responseData;
            }
          } else {
            return {
              'success': true,
              'message': 'Patient status updated successfully',
            };
          }

          final updatedPatient = Patient.fromJson(patientJson);

          return {
            'success': true,
            'message': 'Patient status updated successfully',
            'data': updatedPatient
          };
        } catch (e) {
          print('Error parsing update status response: $e');
          return {
            'success': true,
            'message': 'Patient status updated successfully',
          };
        }
      } else {
        String message;
        try {
          final responseData = jsonDecode(response.body);
          message =
              responseData['message'] ?? 'Failed to update patient status';
        } catch (e) {
          message = 'Failed to update patient status';
        }
        return {
          'success': false,
          'message': message,
        };
      }
    } catch (e) {
      print('Error updating patient status: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
