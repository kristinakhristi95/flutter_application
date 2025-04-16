import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'clinical_data.dart';

enum PatientStatus { 
  stable, 
  critical 
}

extension PatientStatusExtension on PatientStatus {
  String get name {
    switch (this) {
      case PatientStatus.stable:
        return 'Stable';
  
      case PatientStatus.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case PatientStatus.stable:
        return Colors.green;

      case PatientStatus.critical:
        return Colors.red;
    }
  }
  
  static PatientStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'critical':
        return PatientStatus.critical;
      case 'stable':
      default:
        return PatientStatus.stable;
    }
  }
}

class Patient {
  final String? id;
  final String userId;
  final String name;
  final DateTime dob;
  final String gender;
  final String? address;
  final String? contactNumber;
  final PatientStatus status;
  final String condition;
  final DateTime lastChecked;
  final List<ClinicalData> clinicalData;

  Patient({
    this.id,
    required this.userId,
    required this.name,
    required this.dob,
    required this.gender,
    this.address,
    this.contactNumber,
    required this.status,
    this.condition = 'Unknown',
    DateTime? lastChecked,
    List<ClinicalData>? clinicalData,
  }) : lastChecked = lastChecked ?? DateTime.now(),
       clinicalData = clinicalData ?? [];

  factory Patient.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing patient: ${json['name']}');
      
      // Safe date parsing
      DateTime parsedDob;
      try {
        parsedDob = DateTime.parse(json['dob']);
      } catch (e) {
        print('Error parsing DOB: $e');
        parsedDob = DateTime.now().subtract(const Duration(days: 365 * 30)); // Default to 30 years ago
      }
      
      DateTime parsedLastChecked;
      try {
        parsedLastChecked = json['lastChecked'] != null 
            ? DateTime.parse(json['lastChecked']) 
            : DateTime.now();
      } catch (e) {
        print('Error parsing lastChecked: $e');
        parsedLastChecked = DateTime.now();
      }
      
      return Patient(
        id: json['_id'],
        userId: json['userId'] ?? '',
        name: json['name'] ?? 'Unknown',
        dob: parsedDob,
        gender: json['gender'] ?? 'Other',
        address: json['address'],
        contactNumber: json['contactNumber'],
        status: PatientStatusExtension.fromString(json['status'] ?? 'stable'),
        condition: json['condition'] ?? 'Unknown',
        lastChecked: parsedLastChecked,
      );
    } catch (e) {
      print('Error creating Patient from JSON: $e');
      print('JSON data: $json');
      // Return a fallback patient
      return Patient(
        id: json['_id'] ?? 'unknown_id',
        userId: json['userId'] ?? '',
        name: json['name'] ?? 'Error: Invalid Data',
        dob: DateTime.now().subtract(const Duration(days: 365 * 30)),
        gender: 'Other',
        status: PatientStatus.stable,
      );
    }
  }

  Map<String, dynamic> toJson() {
    // Format phone number to contain only digits
    String? formattedPhone;
    if (contactNumber != null && contactNumber!.isNotEmpty) {
      formattedPhone = contactNumber!.replaceAll(RegExp(r'[^\d]'), '');
    }

    return {
      'userId': userId,
      'name': name,
      'dob': dob.toIso8601String(),
      'gender': gender,
      'address': address,
      'contactNumber': formattedPhone,
      'status': status == PatientStatus.critical ? 'Critical' : 'Stable',
    };
  }

  String get formattedDob => DateFormat('MMM dd, yyyy').format(dob);
  
  String get formattedLastChecked => DateFormat('MMM dd, yyyy').format(lastChecked);

  int get age {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }
}
