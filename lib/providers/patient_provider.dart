import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../services/patient_service.dart';

class PatientProvider extends ChangeNotifier {
  List<Patient> _patients = [];
  List<Patient> _criticalPatients = [];
  bool _isLoading = false;
  String? _error;

  List<Patient> get patients => _patients;
  List<Patient> get criticalPatients => _criticalPatients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllPatients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await PatientService.getAllPatients();
      
      if (result['success']) {
        _patients = result['data'];
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCriticalPatients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await PatientService.getCriticalPatients();
      
      if (result['success']) {
        _criticalPatients = result['data'];
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Patient?> getPatientById(String patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await PatientService.getPatientById(patientId);
      
      if (result['success']) {
        _isLoading = false;
        notifyListeners();
        return result['data'];
      } else {
        _error = result['message'];
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> addPatient(Patient patient) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await PatientService.addPatient(patient);
      
      if (result['success']) {
        // Add to local list
        _patients.add(result['data']);
        // If critical, add to critical list
        if (patient.status == PatientStatus.critical) {
          _criticalPatients.add(result['data']);
        }
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePatient(String patientId, Patient patient) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await PatientService.updatePatient(patientId, patient);
      
      if (result['success']) {
        // Update in local list
        final index = _patients.indexWhere((p) => p.id == patientId);
        if (index != -1) {
          _patients[index] = result['data'];
        }
        
        // Update in critical list if needed
        final criticalIndex = _criticalPatients.indexWhere((p) => p.id == patientId);
        if (patient.status == PatientStatus.critical) {
          if (criticalIndex == -1) {
            // Add to critical if not there
            _criticalPatients.add(result['data']);
          } else {
            // Update if already in critical
            _criticalPatients[criticalIndex] = result['data'];
          }
        } else if (criticalIndex != -1) {
          // Remove from critical if no longer critical
          _criticalPatients.removeAt(criticalIndex);
        }
        
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePatient(String patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await PatientService.deletePatient(patientId);
      
      if (result['success']) {
        // Remove from local lists
        _patients.removeWhere((p) => p.id == patientId);
        _criticalPatients.removeWhere((p) => p.id == patientId);
        notifyListeners();
        return true;
      } else {
        _error = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Combined method to fetch both regular and critical patients
  Future<void> fetchPatients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch both types of patients concurrently
      final results = await Future.wait([
        PatientService.getAllPatients(),
        PatientService.getCriticalPatients()
      ]);

      if (results[0]['success'] && results[1]['success']) {
        _patients = results[0]['data'];
        _criticalPatients = results[1]['data'];
      } else {
        _error = results[0]['success'] ? results[1]['message'] : results[0]['message'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
