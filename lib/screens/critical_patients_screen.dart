import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../widgets/patient_card.dart';

class CriticalPatientsScreen extends StatelessWidget {
  final List<Patient> patients;

  const CriticalPatientsScreen({
    super.key,
    required this.patients,
  });

  @override
  Widget build(BuildContext context) {
    final criticalPatients =
        patients.where((p) => p.status == PatientStatus.critical).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Critical Patients'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Critical Patients (${criticalPatients.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: criticalPatients.isEmpty
                ? const Center(
                    child: Text(
                      'No critical patients',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: criticalPatients.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return PatientCard(patient: criticalPatients[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
