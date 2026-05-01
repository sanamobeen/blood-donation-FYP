import 'package:flutter/material.dart';
import 'models/blood_request_model.dart';
import 'services/blood_request_service.dart';

class MyBloodRequestsPage extends StatefulWidget {
  const MyBloodRequestsPage({super.key});

  @override
  State<MyBloodRequestsPage> createState() => _MyBloodRequestsPageState();
}

class _MyBloodRequestsPageState extends State<MyBloodRequestsPage> {
  List<BloodRequest> _bloodRequests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBloodRequests();
  }

  Future<void> _loadBloodRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await BloodRequestService.getMyBloodRequests();

      if (result.success && result.bloodRequests != null) {
        setState(() {
          _bloodRequests = result.bloodRequests!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result.errorMessage ;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Show error with option to use mock data
      setState(() {
        _errorMessage = 'Connection Error: ${e.toString()}\n\nMake sure backend is running on http://192.168.56.1:8000';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red.shade900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Blood Requests",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadBloodRequests,
          ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _loadBloodRequests,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Try Again"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _loadMockData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Load Sample Data"),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_bloodRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bloodtype_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No blood requests yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Create your first blood request to see it here",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadMockData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text("Load Sample Data"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBloodRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bloodRequests.length,
        itemBuilder: (context, index) {
          return _buildRequestCard(_bloodRequests[index], isDark);
        },
      ),
    );
  }

  void _loadMockData() {
    setState(() {
      _errorMessage = null;
      _bloodRequests = [
        BloodRequest(
          id: 1,
          patientName: "Ahmed Khan",
          emergencyContact: "0300-1234567",
          bloodGroup: 1,
          bloodGroupName: "A+",
          gender: 1,
          genderName: "Male",
          province: 1,
          provinceName: "Punjab",
          district: 1,
          districtName: "Lahore",
          localLevel: 1,
          localLevelName: "Gulberg",
          unitsRequired: 2,
          requiredDate: "2026-05-10",
          requiredTime: "14:30",
          caseDescription: "Emergency surgery required",
          status: "pending",
          statusDisplay: "PENDING",
          createdAt: DateTime.now(),
        ),
        BloodRequest(
          id: 2,
          patientName: "Fatima Ali",
          emergencyContact: "0301-2345678",
          bloodGroup: 2,
          bloodGroupName: "B+",
          gender: 2,
          genderName: "Female",
          province: 1,
          provinceName: "Punjab",
          district: 2,
          districtName: "Rawalpindi",
          localLevel: 2,
          localLevelName: "Saddar",
          unitsRequired: 3,
          requiredDate: "2026-05-05",
          requiredTime: "10:00",
          caseDescription: "Accident case",
          status: "fulfilled",
          statusDisplay: "FULFILLED",
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
    });
  }

  Widget _buildRequestCard(BloodRequest request, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade900,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.patientName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.bloodGroupName ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.statusDisplay ?? request.status?.toUpperCase() ?? 'UNKNOWN',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  isDark,
                  Icons.calendar_today,
                  "Required Date",
                  request.formattedDate,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  isDark,
                  Icons.access_time,
                  "Required Time",
                  request.formattedTime,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  isDark,
                  Icons.location_on,
                  "Location",
                  "${request.localLevelName ?? 'Unknown'}, ${request.districtName ?? 'Unknown'}",
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  isDark,
                  Icons.bloodtype,
                  "Units Required",
                  "${request.unitsRequired}",
                ),
                if (request.caseDescription != null && request.caseDescription!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    isDark,
                    Icons.description,
                    "Case",
                    request.caseDescription!,
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  "Request ID: #${request.id}",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(bool isDark, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.red.shade900, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'fulfilled':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
