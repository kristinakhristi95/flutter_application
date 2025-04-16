import 'package:flutter/material.dart';

class Patient {
  final String name;
  final int age;

  Patient({required this.name, required this.age});
}

class PatientManagement extends StatefulWidget {
  const PatientManagement({super.key});

  @override
  _PatientManagementState createState() => _PatientManagementState();
}

class _PatientManagementState extends State<PatientManagement> {
  final List<Patient> _patients = [];

  void _addPatient(String name, int age) {
    setState(() {
      _patients.add(Patient(name: name, age: age));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Management'),
      ),
      body: ListView.builder(
        itemCount: _patients.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_patients[index].name),
            subtitle: Text('Age: ${_patients[index].age}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logic to add a patient (e.g., show a dialog)
        },
        tooltip: 'Add Patient',
        child: const Icon(Icons.add),
      ),
    );
  }
}
