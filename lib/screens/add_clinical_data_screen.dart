import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/clinical_data.dart';
import '../services/clinical_data_service.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class AddClinicalDataScreen extends StatefulWidget {
  final Patient patient;

  const AddClinicalDataScreen({
    super.key,
    required this.patient,
  });

  @override
  State<AddClinicalDataScreen> createState() => _AddClinicalDataScreenState();
}

class _AddClinicalDataScreenState extends State<AddClinicalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  late DataType _selectedType;
  final TextEditingController _valueController = TextEditingController();
  late DateTime _selectedDateTime;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _selectedType = DataType.bloodPressure;
    _selectedDateTime = DateTime.now();
  }

  String _getUnitForType(DataType type) {
    switch (type) {
      case DataType.bloodPressure:
        return 'mmHg';
      case DataType.heartBeatRate:
        return 'bpm';
      case DataType.bloodOxygenLevel:
        return '%';
      case DataType.respiratoryRate:
        return 'breaths/min';
    }
  }

  String? _validateValue(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    if (_selectedType == DataType.bloodPressure) {
      if (!RegExp(r'^\d+/\d+$').hasMatch(value)) {
        return 'Enter blood pressure in format: 120/80';
      }
    } else {
      if (double.tryParse(value) == null) {
        return 'Please enter a valid number';
      }
    }
    return null;
  }

  Future<void> _saveTestData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final bool isApiAvailable = await ApiConfig.checkApiAvailability();
      if (!mounted) return;

      if (!isApiAvailable) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Server is not available. Please try again later.';
        });
        return;
      }

      final userId = await AuthService.getUserId();
      if (!mounted) return;

      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User is not logged in. Please login again.';
        });
        return;
      }

      final double? numericValue = _selectedType == DataType.bloodPressure
          ? null
          : double.tryParse(_valueController.text);

      final newData = ClinicalData(
        patientId: widget.patient.id ?? '',
        userId: userId,
        type: _selectedType,
        reading: numericValue ?? 0.0,
        testDate: _selectedDateTime,
        value: _valueController.text,
        unit: _getUnitForType(_selectedType),
      );

      final result = await ClinicalDataService.addTest(
        widget.patient.id ?? '',
        newData,
      );

      if (!mounted) return;

      if (result['success']) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Clinical Test'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF2E7D32),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.patient.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Age: ${widget.patient.age} | ${widget.patient.condition}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Test Type
              DropdownButtonFormField<DataType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Test Type',
                  border: OutlineInputBorder(),
                ),
                items: DataType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                      _valueController.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Value
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: 'Value',
                  border: const OutlineInputBorder(),
                  suffixText: _getUnitForType(_selectedType),
                  hintText: _selectedType == DataType.bloodPressure
                      ? 'e.g., 120/80'
                      : 'Enter value',
                ),
                validator: _validateValue,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),

              // Date and Time Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date and Time'),
                subtitle: Text(
                  '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} '
                  '${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveTestData,
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Saving...'),
                          ],
                        )
                      : const Text('Save Test Result'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
