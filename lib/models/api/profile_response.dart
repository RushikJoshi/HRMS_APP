import 'package:json_annotation/json_annotation.dart';

part 'profile_response.g.dart';

@JsonSerializable()
class ProfileResponse {
  @JsonKey(
    name: 'success',
    defaultValue: false,
    fromJson: _boolFromJson,
  )
  final bool success;
  final String? message;
  final ProfileData? data;

  ProfileResponse({
    this.success = false,
    this.message,
    this.data,
  });

  static bool _boolFromJson(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return false;
  }

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    // Check if the response matches the standard wrapper structure
    if (json.containsKey('success') || json.containsKey('data')) {
      return _$ProfileResponseFromJson(json);
    }
    
    // Fallback: Assume the response IS the profile data directly (unwrapped)
    return ProfileResponse(
      success: true,
      message: 'Profile loaded',
      data: ProfileData.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);

  @override
  String toString() => 'ProfileResponse(success: $success, message: $message, data: $data)';
}

class ProfileData {
  final String? id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? name; // Kept for backward compatibility if API sends 'name'
  final String? email;
  final String? employeeId;
  final String? companyCode;
  final String? designation;
  final String? department;
  final String? phone;
  final String? address;
  final String? dateOfBirth;
  final String? joiningDate;
  final String? profilePhoto;
  final String? gender;
  final String? bloodGroup;
  final String? maritalStatus;
  final String? nationality;
  final String? fatherName;
  final String? motherName;
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? jobType;
  final String? role;
  final TempAddress? tempAddress;
  final PermAddress? permAddress;
  final BankDetails? bankDetails;
  final DepartmentId? departmentId;
  final Map<String, dynamic>? additionalInfo;
  final Education? education;
  final Documents? documents;
  final LeavePolicy? leavePolicy;

  ProfileData({
    this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    this.name,
    this.email,
    this.employeeId,
    this.companyCode,
    this.designation,
    this.department,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.joiningDate,
    this.profilePhoto,
    this.gender,
    this.bloodGroup,
    this.maritalStatus,
    this.nationality,
    this.fatherName,
    this.motherName,
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.jobType,
    this.role,
    this.tempAddress,
    this.permAddress,
    this.bankDetails,
    this.departmentId,
    this.additionalInfo,
    this.education,
    this.documents,
    this.leavePolicy,
  });

  // Getter for full name
  String get fullName {
    final parts = [firstName, lastName].where((s) => s != null && s.isNotEmpty).toList();
    if (parts.isNotEmpty) {
      return parts.join(' ');
    }
    if (name != null && name!.isNotEmpty) return name!;
    return 'N/A';
  }

  double get profileCompletionPercentage {
    final fields = [
      firstName, lastName, email, employeeId, designation, department, phone, 
      address, dateOfBirth, joiningDate, profilePhoto, gender, bloodGroup,
      maritalStatus, nationality, fatherName, motherName, jobType
    ];
    final filledFields = fields.where((f) => f != null && f.toString().isNotEmpty).length;
    
    // Weighted sub-sections
    int subProgress = 0;
    if (tempAddress != null) subProgress++;
    if (permAddress != null) subProgress++;
    if (bankDetails != null) subProgress++;
    if (education != null) subProgress++;
    if (documents != null) subProgress++;
    
    // Normalized calculation
    const int totalFields = 18 + 5; // Basic fields + sub-objects
    final int totalFilled = filledFields + subProgress;
    
    return (totalFilled / totalFields) * 100;
  }

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['_id'] as String?,
      firstName: json['firstName'] as String?,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      employeeId: json['employeeId'] as String?,
      companyCode: json['companyCode'] as String?,
      designation: json['designation'] as String?,
      department: json['department'] as String?,
      phone: json['contactNo'] as String? ?? json['phone'] as String?,
      address: json['address'] as String?,
      dateOfBirth: json['dob'] as String? ?? json['dateOfBirth'] as String?,
      joiningDate: json['joiningDate'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      gender: json['gender'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      nationality: json['nationality'] as String?,
      fatherName: json['fatherName'] as String?,
      motherName: json['motherName'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactNumber: json['emergencyContactNumber'] as String?,
      jobType: json['jobType'] as String?,
      role: json['role'] as String?,
      tempAddress: json['tempAddress'] != null ? TempAddress.fromJson(json['tempAddress']) : null,
      permAddress: json['permAddress'] != null ? PermAddress.fromJson(json['permAddress']) : null,
      bankDetails: json['bankDetails'] != null ? BankDetails.fromJson(json['bankDetails']) : null,
      departmentId: json['departmentId'] != null ? DepartmentId.fromJson(json['departmentId']) : null,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      education: json['education'] != null ? Education.fromJson(json['education']) : null,
      documents: json['documents'] != null ? Documents.fromJson(json['documents']) : null,
      leavePolicy: json['leavePolicy'] != null ? LeavePolicy.fromJson(json['leavePolicy']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'name': name,
      'email': email,
      'employeeId': employeeId,
      'companyCode': companyCode,
      'designation': designation,
      'department': department,
      'contactNo': phone,
      'address': address,
      'dob': dateOfBirth,
      'joiningDate': joiningDate,
      'profilePhoto': profilePhoto,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'maritalStatus': maritalStatus,
      'nationality': nationality,
      'fatherName': fatherName,
      'motherName': motherName,
      'emergencyContactName': emergencyContactName,
      'emergencyContactNumber': emergencyContactNumber,
      'jobType': jobType,
      'role': role,
      'tempAddress': tempAddress?.toJson(),
      'permAddress': permAddress?.toJson(),
      'bankDetails': bankDetails?.toJson(),
      'departmentId': departmentId?.toJson(),
      'additionalInfo': additionalInfo,
      'education': education?.toJson(),
      'documents': documents?.toJson(),
      'leavePolicy': leavePolicy?.toJson(),
    };
  }
}

@JsonSerializable()
class LeavePolicy {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;
  final List<LeaveRule>? rules;

  LeavePolicy({this.id, this.name, this.rules});

  factory LeavePolicy.fromJson(Map<String, dynamic> json) => _$LeavePolicyFromJson(json);
  Map<String, dynamic> toJson() => _$LeavePolicyToJson(this);
}

@JsonSerializable()
class LeaveRule {
  final String? leaveType;
  final double? totalPerYear; // Changed to double to support 1.5 etc if needed, though log said 12
  final String? color;
  // Add other fields from log if needed: monthlyAccrual, accrualType, etc.
  
  LeaveRule({this.leaveType, this.totalPerYear, this.color});

  factory LeaveRule.fromJson(Map<String, dynamic> json) => _$LeaveRuleFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveRuleToJson(this);
}

@JsonSerializable()
class Education {
  final String? type;
  final String? class10Marksheet;
  final String? diplomaCertificate;
  final String? bachelorDegree;

  Education({
    this.type,
    this.class10Marksheet,
    this.diplomaCertificate,
    this.bachelorDegree,
  });

  factory Education.fromJson(Map<String, dynamic> json) => _$EducationFromJson(json);
  Map<String, dynamic> toJson() => _$EducationToJson(this);
}

@JsonSerializable()
class Documents {
  final String? aadharFront;
  final String? aadharBack;
  final String? panCard;

  Documents({
    this.aadharFront,
    this.aadharBack,
    this.panCard,
  });

  factory Documents.fromJson(Map<String, dynamic> json) => _$DocumentsFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentsToJson(this);
}

@JsonSerializable()
class TempAddress {
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? pinCode;
  final String? country;

  TempAddress({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.pinCode,
    this.country,
  });

  String get fullAddress {
    final parts = <String>[];
    if (line1 != null && line1!.isNotEmpty) parts.add(line1!);
    if (line2 != null && line2!.isNotEmpty) parts.add(line2!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (pinCode != null && pinCode!.isNotEmpty) parts.add(pinCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  factory TempAddress.fromJson(Map<String, dynamic> json) =>
      _$TempAddressFromJson(json);

  Map<String, dynamic> toJson() => _$TempAddressToJson(this);
}

@JsonSerializable()
class PermAddress {
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? pinCode;
  final String? country;

  PermAddress({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.pinCode,
    this.country,
  });

  String get fullAddress {
    final parts = <String>[];
    if (line1 != null && line1!.isNotEmpty) parts.add(line1!);
    if (line2 != null && line2!.isNotEmpty) parts.add(line2!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (pinCode != null && pinCode!.isNotEmpty) parts.add(pinCode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  factory PermAddress.fromJson(Map<String, dynamic> json) =>
      _$PermAddressFromJson(json);

  Map<String, dynamic> toJson() => _$PermAddressToJson(this);
}

@JsonSerializable()
class BankDetails {
  final String? bankName;
  final String? accountNumber;
  final String? ifsc;
  final String? branchName;

  BankDetails({
    this.bankName,
    this.accountNumber,
    this.ifsc,
    this.branchName,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) =>
      _$BankDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$BankDetailsToJson(this);
}

@JsonSerializable()
class DepartmentId {
  @JsonKey(name: '_id')
  final String? id;
  final String? name;

  DepartmentId({
    this.id,
    this.name,
  });

  factory DepartmentId.fromJson(Map<String, dynamic> json) =>
      _$DepartmentIdFromJson(json);

  Map<String, dynamic> toJson() => _$DepartmentIdToJson(this);
}

