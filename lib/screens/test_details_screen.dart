import 'package:flutter/material.dart';
import '../models/clinical_data.dart';
import '../models/patient.dart';
import '../services/clinical_data_service.dart';

class TestDetailsScreen extends StatefulWidget {
  final ClinicalData test;
  final Patient patient;

  const TestDetailsScreen({
    super.key,
    required this.test,
    required this.patient,
  });

  @override
  State<TestDetailsScreen> createState() => _TestDetailsScreenState();
}

class _TestDetailsScreenState extends State<TestDetailsScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  String _error = '';
  late TextEditingController _readingController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _readingController = TextEditingController(text: widget.test.readingValue.toString());
    _selectedDate = widget.test.testDate;
  }

  @override
  void dispose() {
    _readingController.dispose();
    super.dispose();
  }

  Future<void> _updateTest() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final result = await ClinicalDataService.updateTest(
        widget.test.id!,
        {
          'dataType': widget.test.type.name,
          'reading': double.parse(_readingController.text),
          'testDate': _selectedDate.toIso8601String(),
        },
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Test updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Indicate refresh
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to update test';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _getUnitForType(DataType type) {
    switch (type) {
      case DataType.bloodPressure:
        return 'mmHg';
      case DataType.respiratoryRate:
        return 'breaths/min';
      case DataType.bloodOxygenLevel:
        return '%';
      case DataType.heartBeatRate:
        return 'bpm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Details'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(_error, style: const TextStyle(color: Colors.red)),
              ),

            // Patient Info
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          Text(widget.patient.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

            const Text(
              'Test Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildInfoTile(
              icon: Icons.medical_services,
              title: 'Test Type',
              value: widget.test.type.name,
            ),

            _buildInfoTile(
              icon: Icons.monitor_heart,
              title: 'Reading',
              value: _isEditing
                  ? null
                  : '${widget.test.readingValue} ${_getUnitForType(widget.test.type)}',
              child: _isEditing
                  ? TextField(
                      controller: _readingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter reading value',
                        suffixText: _getUnitForType(widget.test.type),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    )
                  : null,
            ),

            _buildInfoTile(
              icon: Icons.calendar_today,
              title: 'Test Date & Time',
              value: !_isEditing
                  ? '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} '
                      '${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}'
                  : null,
              child: _isEditing
                  ? TextButton.icon(
                      icon: const Icon(Icons.edit_calendar),
                      label: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} '
                        '${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                      ),
                      onPressed: _selectDate,
                    )
                  : null,
            ),

            _buildInfoTile(
              icon: Icons.warning,
              title: 'Status',
              value: widget.test.criticalFlag ? 'Critical' : 'Normal',
              iconColor: widget.test.criticalFlag ? Colors.red : Colors.green,
              valueColor: widget.test.criticalFlag ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isEditing
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Save Changes'),
              ),
            )
          : null,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    String? value,
    Widget? child,
    Color? iconColor,
    Color? valueColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      leading: Icon(icon, color: iconColor ?? const Color(0xFF2E7D32)),
      title: Text(title),
      subtitle: child ??
          Text(
            value ?? '',
            style: TextStyle(color: valueColor ?? Colors.black),
          ),
    );
  }
}
