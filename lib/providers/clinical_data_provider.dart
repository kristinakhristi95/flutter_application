import 'package:flutter/foundation.dart';
import '../models/clinical_data.dart';
import '../services/clinical_data_service.dart';

class ClinicalDataProvider extends ChangeNotifier {
  final Map<String, List<ClinicalData>> _patientTests = {};
  List<ClinicalData> _criticalTests = [];
  bool _isLoading = false;
  String? _error;

  List<ClinicalData> getTestsForPatient(String patientId) => 
      _patientTests[patientId] ?? [];
  
  List<ClinicalData> get criticalTests => _criticalTests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTestsForPatient(String patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ClinicalDataService.getTestsByPatientId(patientId);
      
      if (result['success']) {
        _patientTests[patientId] = result['data'];
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

  Future<void> fetchCriticalTests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ClinicalDataService.getCriticalTests();
      
      if (result['success']) {
        _criticalTests = result['data'];
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

  Future<ClinicalData?> getTestById(String testId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ClinicalDataService.getTestById(testId);
      
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

  Future<bool> addTest(String patientId, ClinicalData test) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ClinicalDataService.addTest(patientId, test);
      
      if (result['success']) {
        // Add to patient tests
        if (!_patientTests.containsKey(patientId)) {
          _patientTests[patientId] = [];
        }
        _patientTests[patientId]!.add(result['data']);
        
        // Add to critical tests if flagged
        if (test.criticalFlag) {
          _criticalTests.add(result['data']);
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

  Future<bool> updateTest(String testId, ClinicalData test) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ClinicalDataService.updateTest(testId, test.toJson());
      
      if (result['success']) {
        final updatedTest = result['data'];
        
        // Update in patient tests
        for (final patientId in _patientTests.keys) {
          final index = _patientTests[patientId]!.indexWhere((t) => t.id == testId);
          if (index != -1) {
            _patientTests[patientId]![index] = updatedTest;
            break;
          }
        }
        
        // Update in critical tests if needed
        final criticalIndex = _criticalTests.indexWhere((t) => t.id == testId);
        if (test.criticalFlag) {
          if (criticalIndex == -1) {
            // Add to critical if not there
            _criticalTests.add(updatedTest);
          } else {
            // Update if already in critical
            _criticalTests[criticalIndex] = updatedTest;
          }
        } else if (criticalIndex != -1) {
          // Remove from critical if no longer critical
          _criticalTests.removeAt(criticalIndex);
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

  Future<bool> deleteTest(String testId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ClinicalDataService.deleteTest(testId);
      
      if (result['success']) {
        // Remove from patient tests
        for (final patientId in _patientTests.keys) {
          _patientTests[patientId]!.removeWhere((t) => t.id == testId);
        }
        
        // Remove from critical tests
        _criticalTests.removeWhere((t) => t.id == testId);
        
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
