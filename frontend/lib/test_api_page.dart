import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config/api_config.dart';

class TestApiPage extends StatefulWidget {
  const TestApiPage({super.key});

  @override
  State<TestApiPage> createState() => _TestApiPageState();
}

class _TestApiPageState extends State<TestApiPage> {
  String _testResult = '';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing connection...';
    });

    try {
      // Test different URLs
      final urls = [
        'Local: ${ApiConfig.localUrl}',
        'Emulator: ${ApiConfig.emulatorUrl}',
        'Device: ${ApiConfig.deviceUrl}',
        'iOS: ${ApiConfig.iosUrl}',
        'Current Base: ${ApiConfig.baseUrl}',
      ];

      setState(() {
        _testResult = 'URLs:\n${urls.join('\n')}\n\nTesting login endpoint...';
      });

      // Test the actual login endpoint
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/accounts/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'admin@blooddonation.com',
          'password': 'Admin@123',
        }),
      ).timeout(const Duration(seconds: 10));

      setState(() {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _testResult = '✅ SUCCESS!\n\n'
              'Status: ${response.statusCode}\n'
              'URL: ${ApiConfig.baseUrl}\n'
              'Response: ${data['message']}\n\n'
              'User: ${data['data']['user']['email']}\n'
              'Tokens received: ${data['data']['tokens'].length}';
        } else {
          _testResult = '❌ FAILED!\n\n'
              'Status: ${response.statusCode}\n'
              'URL: ${ApiConfig.baseUrl}\n'
              'Response: ${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ ERROR!\n\n'
            'URL: ${ApiConfig.baseUrl}\n'
            'Error: ${e.toString()}\n\n'
            'Possible causes:\n'
            '• Server not running on port 8001\n'
            '• Wrong URL for your platform\n'
            '• Network connectivity issue\n'
            '• Firewall blocking connection';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
        backgroundColor: Colors.red.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade900,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test API Connection',
                      style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Configuration:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Base URL: ${ApiConfig.baseUrl}',
              style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Test Result:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _testResult.isEmpty ? 'Press "Test API Connection" to start' : _testResult,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: _testResult.contains('✅') ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
