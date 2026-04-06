class EmployeeOption {
  final String id;
  final String name;
  final String? employeeId;
  final String? designation;

  EmployeeOption({
    required this.id, 
    required this.name, 
    this.employeeId, 
    this.designation
  });
  
  factory EmployeeOption.fromJson(Map<String, dynamic> json) {
    // Handle potential null or different key names based on backend
    String composedName = json['name'] as String? ?? '';
    if (composedName.isEmpty) {
       composedName = '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();
    }
    
    return EmployeeOption(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: composedName.isEmpty ? 'Unknown' : composedName,
      employeeId: json['employeeId'] as String?,
      designation: json['designation'] as String?,
    );
  }
}
