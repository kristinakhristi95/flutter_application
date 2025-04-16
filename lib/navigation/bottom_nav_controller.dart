import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/dashboard_screen.dart';
import '../screens/tests_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/menu_screen.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;

class BottomNavController extends StatefulWidget {
  const BottomNavController({super.key});

  @override
  State<BottomNavController> createState() => _BottomNavControllerState();
}

class _BottomNavControllerState extends State<BottomNavController> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  List<Patient> _patients = [];
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkApiAndFetchData();
    });
  }

  Future<void> _checkApiAndFetchData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = '';
    });

    try {
      final isAvailable = await ApiConfig.checkApiAvailability();
      if (!isAvailable) {
        try {
          await http.get(Uri.parse(ApiConfig.baseUrl)).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Wake-up request timed out'),
          );
        } catch (_) {}
        await Future.delayed(const Duration(seconds: 2));
      }

      await _fetchPatients();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Failed to connect to server: ${e.toString()}';
      });
      _showErrorSnackBar();
    }
  }

  Future<void> _fetchPatients() async {
    try {
      final provider = Provider.of<PatientProvider>(context, listen: false);
      await provider.fetchAllPatients();
      await provider.fetchCriticalPatients();

      if (!mounted) return;
      final patients = provider.patients;
      setState(() {
        _patients = patients;
        _isLoading = false;
        _isError = false;
        _retryCount = 0;
      });

      if (patients.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No patients found. Add patients to get started.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
      _showErrorSnackBar();
    }
  }

  void _showErrorSnackBar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error loading data: $_errorMessage'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            _retryCount++;
            if (_retryCount <= _maxRetries) {
              Future.delayed(Duration(seconds: _retryCount), () {
                _checkApiAndFetchData();
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Maximum retry attempts reached.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildRetryView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkApiAndFetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? _buildRetryView()
              : DashboardScreen(
                  patients: _patients,
                  onRefresh: _checkApiAndFetchData,
                ),
      const ProfileScreen(),
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? _buildRetryView()
              : TestsScreen(patients: _patients),
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isError
              ? _buildRetryView()
              : MenuScreen(patients: _patients),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services),
              label: 'Tests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }
}
