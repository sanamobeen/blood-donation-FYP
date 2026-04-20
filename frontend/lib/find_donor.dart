import 'package:flutter/material.dart';

class FindDonorsPage extends StatelessWidget {
  const FindDonorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        elevation: 0,
        title: const Text('Find Donors', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: const Center(
        child: Text('Find Donors Page - Coming Soon'),
      ),
    );
  }
}
