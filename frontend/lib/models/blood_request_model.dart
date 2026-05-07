/// Blood Request Model
/// Represents a blood request with all related information
class BloodRequest {
  final int? id;
  final int? user;
  final String? userEmail;
  final String? userName;
  final String patientName;
  final String emergencyContact;
  final String bloodGroup;  // Changed from int to String
  final String? bloodGroupName;
  final String gender;  // Changed from int to String
  final String? genderName;
  final String province;  // Changed from int to String
  final String? provinceName;
  final String district;  // Changed from int to String
  final String? districtName;
  final String localLevel;  // Changed from int to String
  final String? localLevelName;
  final int unitsRequired;
  final String requiredDate;
  final String requiredTime;
  final String? caseDescription;
  final String? status;
  final String? statusDisplay;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BloodRequest({
    this.id,
    this.user,
    this.userEmail,
    this.userName,
    required this.patientName,
    required this.emergencyContact,
    required this.bloodGroup,
    this.bloodGroupName,
    required this.gender,
    this.genderName,
    required this.province,
    this.provinceName,
    required this.district,
    this.districtName,
    required this.localLevel,
    this.localLevelName,
    required this.unitsRequired,
    required this.requiredDate,
    required this.requiredTime,
    this.caseDescription,
    this.status,
    this.statusDisplay,
    this.createdAt,
    this.updatedAt,
  });

  /// Create BloodRequest from JSON
  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      id: json['id'],
      user: json['user'],
      userEmail: json['user_email'],
      userName: json['user_name'],
      patientName: json['patient_name'] ?? '',
      emergencyContact: json['emergency_contact'] ?? '',
      bloodGroup: json['blood_group'] ?? 'A+',  // String-based
      bloodGroupName: json['blood_group_name'],
      gender: json['gender'] ?? 'Male',  // String-based
      genderName: json['gender_name'],
      province: json['province'] ?? 'Punjab',  // String-based
      provinceName: json['province_name'],
      district: json['district'] ?? 'Lahore',  // String-based
      districtName: json['district_name'],
      localLevel: json['local_level'] ?? '',  // Empty string when not provided
      localLevelName: json['local_level_name'],
      unitsRequired: json['units_required'] ?? 1,
      requiredDate: json['required_date'] ?? '',
      requiredTime: json['required_time'] ?? '',
      caseDescription: json['case'],
      status: json['status'],
      statusDisplay: json['status_display'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'patient_name': patientName,
      'emergency_contact': emergencyContact,
      'blood_group': bloodGroup,
      'gender': gender,
      'province': province,
      'district': district,
      'local_level': localLevel,
      'units_required': unitsRequired,
      'required_date': requiredDate,
      'required_time': requiredTime,
      if (caseDescription != null && caseDescription!.isNotEmpty)
        'case': caseDescription,
    };
  }

  /// Get formatted date for display
  String get formattedDate {
    try {
      final date = DateTime.parse(requiredDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return requiredDate;
    }
  }

  /// Get formatted time for display (12-hour format with AM/PM)
  String get formattedTime {
    try {
      final time = requiredTime.split(':');
      final hour = int.parse(time[0]);
      final minute = int.parse(time[1].split(':')[0]);

      // Convert to 12-hour format
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return requiredTime;
    }
  }
}

/// Location data models
class Province {
  final String id;  // Changed from int to String
  final String name;
  final String? code;

  Province({
    required this.id,
    required this.name,
    this.code,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}

class District {
  final String id;  // Changed from int to String
  final String name;
  final String? province;  // Also changed to String

  District({
    required this.id,
    required this.name,
    this.province,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
      province: json['province'],  // Will be null if not provided
    );
  }
}

class LocalLevel {
  final int id;
  final String name;
  final int district;

  LocalLevel({
    required this.id,
    required this.name,
    required this.district,
  });

  factory LocalLevel.fromJson(Map<String, dynamic> json) {
    return LocalLevel(
      id: json['id'],
      name: json['name'],
      district: json['district'],
    );
  }
}

class BloodGroup {
  final String id;  // Changed from int to String
  final String name;

  BloodGroup({
    required this.id,
    required this.name,
  });

  factory BloodGroup.fromJson(Map<String, dynamic> json) {
    return BloodGroup(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Gender {
  final String id;  // Changed from int to String
  final String name;

  Gender({
    required this.id,
    required this.name,
  });

  factory Gender.fromJson(Map<String, dynamic> json) {
    return Gender(
      id: json['id'],
      name: json['name'],
    );
  }
}
