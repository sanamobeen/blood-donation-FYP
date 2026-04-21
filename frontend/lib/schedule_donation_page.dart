import 'package:flutter/material.dart';
import 'profile_page.dart';

class ScheduleDonationPage extends StatefulWidget {
  const ScheduleDonationPage({super.key});

  @override
  State<ScheduleDonationPage> createState() => _ScheduleDonationPageState();
}

class _ScheduleDonationPageState extends State<ScheduleDonationPage> {
  // Selection State Variables
  int _currentStep = 0;
  DateTime? _selectedDate;
  String? _selectedTime;
  String? _selectedCenter;
  String? _selectedDonationType;

  // Eligibility State Variables
  bool _isHealthy = true;
  bool _isAbove50kg = true;
  bool _isBetween18and65 = true;
  bool _noRecentMedications = true;
  bool _setReminder = true;

  // Data Models
  final List<String> _timeSlots = [
    "09:00 AM",
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "02:00 PM",
    "03:00 PM",
    "04:00 PM",
    "05:00 PM",
  ];

  final List<Map<String, dynamic>> _donationCenters = [
    {
      'name': 'City Blood Bank',
      'address': '123 Main Street, Downtown',
      'distance': '2.5 km',
      'hours': '9:00 AM - 6:00 PM',
      'rating': 4.8,
    },
    {
      'name': 'Red Cross Center',
      'address': '456 Oak Avenue, Westside',
      'distance': '3.2 km',
      'hours': '8:00 AM - 5:00 PM',
      'rating': 4.9,
    },
    {
      'name': 'General Hospital',
      'address': '789 Medical Plaza, Eastside',
      'distance': '4.1 km',
      'hours': '24/7',
      'rating': 4.7,
    },
    {
      'name': 'Community Health Center',
      'address': '321 Wellness Road, Northside',
      'distance': '5.0 km',
      'hours': '9:00 AM - 4:00 PM',
      'rating': 4.6,
    },
  ];

  final List<Map<String, dynamic>> _donationTypes = [
    {
      'type': 'Whole Blood',
      'duration': '10-15 mins',
      'description': 'Most common type, saves up to 3 lives',
      'icon': Icons.bloodtype,
      'color': Colors.red,
    },
    {
      'type': 'Platelets',
      'duration': '1.5-2 hours',
      'description': 'Helps cancer patients, clotting disorders',
      'icon': Icons.water_drop,
      'color': Colors.amber,
    },
    {
      'type': 'Plasma',
      'duration': '1-1.5 hours',
      'description': 'Helps burn, trauma patients',
      'icon': Icons.science,
      'color': Colors.blue,
    },
    {
      'type': 'Double Red Cells',
      'duration': '30-45 mins',
      'description': 'Two units of red cells, fewer donations needed',
      'icon': Icons.favorite,
      'color': Colors.pink,
    },
  ];

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
          "Schedule Donation",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _handleNext,
        onStepCancel: _handleCancel,
        onStepTapped: (step) => setState(() => _currentStep = step),
        steps: _steps,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade900),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canContinue() ? details.onStepContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentStep == _steps.length - 1
                          ? 'Confirm Booking'
                          : 'Next',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Step> get _steps => [
        Step(
          title: const Text('Date & Time'),
          content: _buildDateTimeStep(),
          isActive: _currentStep == 0,
          state: _currentStep == 0 ? StepState.editing : StepState.indexed,
        ),
        Step(
          title: const Text('Center'),
          content: _buildCenterStep(),
          isActive: _currentStep == 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Type'),
          content: _buildTypeStep(),
          isActive: _currentStep == 2,
          state: _currentStep > 2 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Eligibility'),
          content: _buildEligibilityStep(),
          isActive: _currentStep == 3,
          state: _currentStep > 3 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Confirm'),
          content: _buildConfirmStep(),
          isActive: _currentStep == 4,
          state: _currentStep == 4 ? StepState.editing : StepState.indexed,
        ),
      ];

  // STEP 1: Date & Time Selection
  Widget _buildDateTimeStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Selection
        Text(
          "Select Date",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index + 1));
              // Skip Sundays
              if (date.weekday == 7) return const SizedBox.shrink();

              final isSelected = _selectedDate != null &&
                  _selectedDate!.day == date.day &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.year == date.year;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDate = date);
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red.shade900 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getWeekday(date.weekday),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      Text(
                        _getMonth(date.month),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        // Time Selection
        Text(
          "Select Time Slot",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _timeSlots.length,
          itemBuilder: (context, index) {
            final time = _timeSlots[index];
            final isSelected = _selectedTime == time;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedTime = time);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.red.shade900
                      : (isDark
                          ? Colors.grey.shade800
                          : Colors.white),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Colors.red.shade900
                        : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // STEP 2: Donation Center Selection
  Widget _buildCenterStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Donation Center",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _donationCenters.length,
          itemBuilder: (context, index) {
            final center = _donationCenters[index];
            final isSelected = _selectedCenter == center['name'];

            return GestureDetector(
              onTap: () {
                setState(() => _selectedCenter = center['name']);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.red.shade50
                      : (isDark
                          ? Colors.grey.shade800
                          : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.red.shade900
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            center['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            center['address'],
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  center['hours'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.directions_walk,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  center['distance'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${center['rating']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Colors.red.shade900,
                            size: 24,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // STEP 3: Donation Type Selection
  Widget _buildTypeStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Donation Type",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _donationTypes.length,
          itemBuilder: (context, index) {
            final type = _donationTypes[index];
            final isSelected = _selectedDonationType == type['type'];
            final color = type['color'] as Color;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedDonationType = type['type']);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.1)
                      : (isDark
                          ? Colors.grey.shade800
                          : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        type['icon'] as IconData,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type['type'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type['description'],
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 14,
                                color: color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                type['duration'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: color,
                        size: 28,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // STEP 4: Eligibility Check
  Widget _buildEligibilityStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade900, width: 2),
          ),
          child: Row(
            children: [
              const Icon(Icons.info, color: Colors.blue, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Please answer these questions to ensure you're eligible to donate",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Eligibility Check",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        _buildEligibilityCheckbox(
          isDark,
          "I am in good health today",
          _isHealthy,
          (value) => setState(() => _isHealthy = value),
        ),
        _buildEligibilityCheckbox(
          isDark,
          "I weigh 50 kg or more",
          _isAbove50kg,
          (value) => setState(() => _isAbove50kg = value),
        ),
        _buildEligibilityCheckbox(
          isDark,
          "I am between 18-65 years old",
          _isBetween18and65,
          (value) => setState(() => _isBetween18and65 = value),
        ),
        _buildEligibilityCheckbox(
          isDark,
          "I haven't taken any medications in the last 7 days",
          _noRecentMedications,
          (value) => setState(() => _noRecentMedications = value),
        ),
      ],
    );
  }

  Widget _buildEligibilityCheckbox(
    bool isDark,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? Colors.green : Colors.grey.shade300,
          width: value ? 2 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (val) => onChanged(val ?? false),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        activeColor: Colors.green,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  // STEP 5: Confirmation
  Widget _buildConfirmStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Appointment Summary",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildSummaryCard(isDark),
        const SizedBox(height: 20),
        SwitchListTile(
          value: _setReminder,
          onChanged: (value) => setState(() => _setReminder = value),
          title: Text(
            "Set Reminder",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            "Get notified before your appointment",
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          activeThumbColor: Colors.red.shade900,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    // Find selected center and type
    final center = _donationCenters.firstWhere(
      (c) => c['name'] == _selectedCenter,
      orElse: () => _donationCenters[0],
    );
    final donationType = _donationTypes.firstWhere(
      (t) => t['type'] == _selectedDonationType,
      orElse: () => _donationTypes[0],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade900, Colors.red.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Date & Time
          Row(
            children: [
              const Icon(Icons.event, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date & Time",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    if (_selectedDate != null)
                      Text(
                        "${_getWeekday(_selectedDate!.weekday)}, ${_selectedDate!.day} ${_getMonth(_selectedDate!.month)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    else
                      const Text(
                        "Not selected",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    if (_selectedTime != null)
                      Text(
                        _selectedTime!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      )
                    else
                      const Text(
                        "Not selected",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white, thickness: 1),
          const SizedBox(height: 16),
          // Donation Center
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Donation Center",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      center['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      center['address'],
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white, thickness: 1),
          const SizedBox(height: 16),
          // Donation Type
          Row(
            children: [
              const Icon(Icons.bloodtype, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Donation Type",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      donationType['type'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      donationType['duration'],
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Methods
  bool _canContinue() {
    switch (_currentStep) {
      case 0: // Date & Time
        return _selectedDate != null && _selectedTime != null;
      case 1: // Center
        return _selectedCenter != null;
      case 2: // Type
        return _selectedDonationType != null;
      case 3: // Eligibility
        return _isHealthy &&
            _isAbove50kg &&
            _isBetween18and65 &&
            _noRecentMedications;
      case 4: // Confirm
        return true;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _bookAppointment();
    }
  }

  void _handleCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  String _getWeekday(int day) {
    const weekdays = [
      '',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];
    return weekdays[day];
  }

  String _getMonth(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }

  void _bookAppointment() {
    final appointmentId =
        'BD${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.green.shade900,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Booking Confirmed!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your appointment has been scheduled successfully",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Appointment ID: $appointmentId",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
