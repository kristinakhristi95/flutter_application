import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/clinical_data.dart';
import '../services/clinical_data_service.dart';
import 'test_details_screen.dart';
import 'package:intl/intl.dart';

class TestsScreen extends StatefulWidget {
  final List<Patient> patients;

  const TestsScreen({super.key, required this.patients});

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  bool _isLoading = true;
  String _error = '';
  List<ClinicalData> _allTests = [];
  List<ClinicalData> _filteredTests = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllTests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTests(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTests = _allTests;
      } else {
        _filteredTests = _allTests.where((test) {
          final patient = widget.patients.firstWhere(
            (p) => p.id == test.patientId,
            orElse: () => Patient(
              name: 'Unknown Patient',
              userId: 'unknown',
              dob: DateTime(1900),
              gender: 'Unknown',
              condition: 'Unknown',
              status: PatientStatus.stable,
            ),
          );

          final search = query.toLowerCase();
          return test.type.name.toLowerCase().contains(search) ||
              patient.name.toLowerCase().contains(search) ||
              DateFormat('dd/MM/yyyy').format(test.testDate).contains(search);
        }).toList();
      }
    });
  }

  Future<void> _loadAllTests() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      List<ClinicalData> allTests = [];

      for (var patient in widget.patients) {
        if (patient.id != null) {
          final result = await ClinicalDataService.getTestsByPatientId(patient.id!);
          if (result['success']) {
            allTests.addAll(result['data'] as List<ClinicalData>);
          }
        }
      }

      if (mounted) {
        setState(() {
          _allTests = allTests;
          _filteredTests = allTests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Tests'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllTests,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by test type, patient or date...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterTests('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterTests,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? _buildErrorUI()
                    : _filteredTests.isEmpty
                        ? _buildEmptyUI()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            itemCount: _filteredTests.length,
                            itemBuilder: (context, index) {
                              final test = _filteredTests[index];
                              final patient = widget.patients.firstWhere(
                                (p) => p.id == test.patientId,
                                orElse: () => Patient(
                                  name: 'Unknown Patient',
                                  userId: 'unknown',
                                  dob: DateTime(1900),
                                  gender: 'Unknown',
                                  condition: 'Unknown',
                                  status: PatientStatus.stable,
                                ),
                              );

                              return _buildTestCard(
                                test,
                                patient,
                                test.criticalFlag ? TestStatus.critical : TestStatus.completed,
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add test functionality
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyUI() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No tests match your search', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTestCard(ClinicalData test, Patient patient, TestStatus status) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF2E7D32),
          child: Icon(Icons.medical_services, color: Colors.white),
        ),
        title: Text(
          test.type.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient: ${patient.name}'),
              Text('Date: ${DateFormat('dd/MM/yyyy').format(test.testDate)}'),
            ],
          ),
        ),
        trailing: _buildStatusChip(status),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TestDetailsScreen(test: test, patient: patient),
            ),
          ).then((refresh) {
            if (refresh == true) {
              _loadAllTests();
            }
          });
        },
      ),
    );
  }

  Widget _buildStatusChip(TestStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        border: Border.all(color: status.color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }
}

enum TestStatus {
  pending,
  completed,
  critical;

  String get label {
    switch (this) {
      case TestStatus.pending:
        return 'Pending';
      case TestStatus.completed:
        return 'Normal';
      case TestStatus.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case TestStatus.pending:
        return Colors.orange;
      case TestStatus.completed:
        return Colors.green;
      case TestStatus.critical:
        return Colors.red;
    }
  }
}
