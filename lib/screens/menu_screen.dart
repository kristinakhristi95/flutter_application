import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../screens/patient_list_screen.dart';
import '../screens/critical_patients_screen.dart';
import '../screens/tests_screen.dart';

class MenuScreen extends StatelessWidget {
  final List<Patient> patients;

  const MenuScreen({
    super.key,
    required this.patients,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuSection(
            context,
            'Patient Management',
            [
              _buildMenuItem(
                icon: Icons.people,
                title: 'All Patients',
                subtitle: 'View and manage all patients',
                onTap: () => _navigateToPatientList(context),
              ),
              _buildMenuItem(
                icon: Icons.warning,
                title: 'Critical Patients',
                subtitle: 'View patients needing immediate attention',
                onTap: () => _navigateToCriticalPatients(context),
              ),
              _buildMenuItem(
                icon: Icons.medical_services,
                title: 'Medical Tests',
                subtitle: 'View and manage patient tests',
                onTap: () => _navigateToTests(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildMenuSection(
            context,
            'Settings',
            [
              _buildMenuItem(
                icon: Icons.settings,
                title: 'App Settings',
                subtitle: 'Configure app preferences',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings screen coming soon!')),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get assistance and view FAQs',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help screen coming soon!')),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                isDestructive: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout action triggered')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToPatientList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PatientListScreen(),
      ),
    );
  }

  void _navigateToCriticalPatients(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CriticalPatientsScreen(patients: patients),
      ),
    );
  }

  void _navigateToTests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestsScreen(patients: patients),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF2E7D32),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
