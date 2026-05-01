/// Blood Request Model
/// Represents a blood request with all related information
class BloodRequest {
  final int? id;
  final int? user;
  final String? userEmail;
  final String? userName;
  final String patientName;
  final String emergencyContact;
  final int bloodGroup;
  final String? bloodGroupName;
  final int gender;
  final String? genderName;
  final int province;
  final String? provinceName;
  final int district;
  final String? districtName;
  final int localLevel;
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
      bloodGroup: json['blood_group'] ?? 1,
      bloodGroupName: json['blood_group_name'],
      gender: json['gender'] ?? 1,
      genderName: json['gender_name'],
      province: json['province'] ?? 1,
      provinceName: json['province_name'],
      district: json['district'] ?? 1,
      districtName: json['district_name'],
      localLevel: json['local_level'] ?? 1,
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

  /// Get formatted time for display
  String get formattedTime {
    try {
      final time = requiredTime.split(':');
      final hour = int.parse(time[0]);
      final minute = int.parse(time[1].split(':')[0]);
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return requiredTime;
    }
  }
}

/// Location data models
class Province {
  final int id;
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
  final int id;
  final String name;
  final int province;

  District({
    required this.id,
    required this.name,
    required this.province,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      name: json['name'],
      province: json['province'],
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
  final int id;
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
  final int id;
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
