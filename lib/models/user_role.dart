
enum UserRole {
  employee(1, 'Employee'),
  senior(2, 'Senior'),
  teamLead(3, 'Team Lead'),
  manager(4, 'Manager'),
  hr(5, 'HR / Admin');

  final int level;
  final String label;

  const UserRole(this.level, this.label);

  bool get isManagerial => level >= 3;
  bool get isSenior => level >= 2;
  bool get isHR => level == 5;
}
