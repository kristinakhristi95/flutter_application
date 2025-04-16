import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../widgets/patient_card.dart';
import 'add_patient_screen.dart';

class DashboardScreen extends StatelessWidget {
  final List<Patient> patients;
  final VoidCallback? onRefresh;

  const DashboardScreen({
    super.key,
    required this.patients,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final criticalPatients =
        patients.where((p) => p.status == PatientStatus.critical).toList();
    final stablePatients =
        patients.where((p) => p.status == PatientStatus.stable).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MediTrack Dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onRefresh,
              tooltip: 'Refresh Data',
            ),
        ],
      ),
      body: patients.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No patients found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add patients to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  if (onRefresh != null)
                    ElevatedButton.icon(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSummaryCard(
                          'Critical',
                          criticalPatients.length,
                          Colors.red,
                          Icons.warning,
                        ),
                        const SizedBox(width: 8),
                        _buildSummaryCard(
                          'Stable',
                          stablePatients.length,
                          const Color(0xFF2E7D32),
                          Icons.check_circle,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Critical Patients Section
                    if (criticalPatients.isNotEmpty) ...[
                      const Text(
                        'Critical Patients',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...criticalPatients.map(
                        (patient) => PatientCard(
                          patient: patient,
                          onRefresh: onRefresh,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Stable Patients Section
                    if (stablePatients.isNotEmpty) ...[
                      const Text(
                        'Stable Patients',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...stablePatients.map(
                        (patient) => PatientCard(
                          patient: patient,
                          onRefresh: onRefresh,
                        ),
                      ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPatientScreen()),
          );
          if (result != null && onRefresh != null) {
            onRefresh!();
          }
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
