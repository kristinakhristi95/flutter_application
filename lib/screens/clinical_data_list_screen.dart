import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/clinical_data.dart';
import 'add_clinical_data_screen.dart';
import 'test_details_screen.dart';

class ClinicalDataListScreen extends StatefulWidget {
  final Patient patient;

  const ClinicalDataListScreen({
    super.key,
    required this.patient,
  });

  @override
  State<ClinicalDataListScreen> createState() => _ClinicalDataListScreenState();
}

class _ClinicalDataListScreenState extends State<ClinicalDataListScreen> {
  String _selectedFilter = 'All';
  late List<ClinicalData> _filteredData;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredData = List.from(widget.patient.clinicalData);
  }

  void _filterData(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredData = List.from(widget.patient.clinicalData);
      } else {
        _filteredData = widget.patient.clinicalData
            .where((data) => data.type.name == filter)
            .toList();
      }
    });
  }

  void _searchData(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterData(_selectedFilter);
      } else {
        _filteredData = widget.patient.clinicalData
            .where((data) =>
                data.type.name.toLowerCase().contains(query.toLowerCase()) ||
                data.value.toString().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Tests'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Patient Info
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF2E7D32),
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.patient.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Age: ${widget.patient.age} | ${widget.patient.condition}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search and Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search tests...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: _searchData,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedFilter,
                  borderRadius: BorderRadius.circular(8),
                  style: const TextStyle(color: Colors.black),
                  items: [
                    const DropdownMenuItem(value: 'All', child: Text('All')),
                    ...DataType.values.map((type) => DropdownMenuItem(
                          value: type.name,
                          child: Text(type.name),
                        )),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _filterData(value);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Clinical Data List
          Expanded(
            child: _filteredData.isEmpty
                ? const Center(
                    child: Text(
                      'No tests found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredData.length,
                    itemBuilder: (context, index) {
                      final data = _filteredData[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: _getIconForDataType(data.type),
                          title: Row(
                            children: [
                              Text(
                                data.type.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                '${data.value} ${data.unit}',
                                style: const TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Date: ${_formatDateTime(data.dateTime)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TestDetailsScreen(
                                  test: data,
                                  patient: widget.patient,
                                ),
                              ),
                            ).then((refreshNeeded) {
                              if (refreshNeeded == true) {
                                setState(() {
                                  _filterData(_selectedFilter);
                                });
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddClinicalDataScreen(patient: widget.patient),
            ),
          );
          if (result != null) {
            setState(() {
              _filterData(_selectedFilter);
            });
          }
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _getIconForDataType(DataType type) {
    IconData iconData;
    switch (type) {
      case DataType.bloodPressure:
        iconData = Icons.favorite;
        break;
      case DataType.respiratoryRate:
        iconData = Icons.air;
        break;
      case DataType.bloodOxygenLevel:
        iconData = Icons.water_drop;
        break;
      case DataType.heartBeatRate:
        iconData = Icons.monitor_heart;
        break;
    }
    return CircleAvatar(
      backgroundColor: const Color(0xFF2E7D32),
      child: Icon(iconData, color: Colors.white, size: 20),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
