
import 'user_role.dart';

class Employee {
  final String id;
  final String name;
  final String designation;
  final UserRole role;
  final String? reportsToId;
  final bool hasTeam;
  final String? profilePhotoUrl;
  final String? email;
  final String? employeeId;
  final String? companyCode;
  final String? department;
  
  // Computed property for easier access
  int get roleLevel => role.level;

  const Employee({
    required this.id,
    required this.name,
    required this.designation,
    required this.role,
    this.reportsToId,
    this.hasTeam = false,
    this.profilePhotoUrl,
    this.email,
    this.employeeId,
    this.companyCode,
    this.department,
  });

  // Factory for testing/mocking
  factory Employee.mock({
    required String id,
    String name = 'John Doe',
    UserRole role = UserRole.employee,
    bool hasTeam = false,
  }) {
    return Employee(
      id: id,
      name: name,
      designation: role.label,
      role: role,
      hasTeam: hasTeam,
    );
  }
}
