import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';
import '../screens/view_clinical_data_screen.dart';
import '../screens/edit_patient_screen.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback? onRefresh;

  const PatientCard({
    super.key,
    required this.patient,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: patient.status.color.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF024A59),
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Row(
                children: [
                  Text(
                    patient.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: patient.status.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      patient.status.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Age: ${patient.age} | Gender: ${patient.gender}'),
                  Text(
                    'Last Checked: ${_formatDateTime(patient.lastChecked)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.medical_services),
                label: const Text('Clinical Data'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewClinicalDataScreen(
                        patient: patient,
                      ),
                    ),
                  );
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPatientScreen(
                        patient: patient,
                      ),
                    ),
                  );
                  if (result != null && onRefresh != null) {
                    onRefresh!();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }
}
