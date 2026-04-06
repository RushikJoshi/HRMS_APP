
import '../models/user_role.dart';
import '../models/employee.dart';

enum AppPermission {
  viewDashboard,
  viewTeam,
  applySelfLeave,
  applyOnBehalfLeave,
  approveLeave,
  delegateAuthority,
  viewOrgStructure,
  viewPayslip,
}

class PermissionResolver {
  /// Central place to define permissions based on Role and Employee attributes.
  static bool can(Employee user, AppPermission permission) {
    switch (permission) {
      case AppPermission.viewDashboard:
      case AppPermission.applySelfLeave:
      case AppPermission.viewPayslip:
        return true; // Everyone
      
      case AppPermission.viewTeam:
        return user.hasTeam; // Only if they have a team
        
      case AppPermission.applyOnBehalfLeave:
        return user.role.level >= UserRole.senior.level; // Level 2+
        
      case AppPermission.approveLeave:
        return user.role.level >= UserRole.teamLead.level; // Level 3+
        
      case AppPermission.delegateAuthority:
        return user.role.level >= UserRole.manager.level; // Level 4+
        
      case AppPermission.viewOrgStructure:
        return user.role.level >= UserRole.manager.level; // Level 4+
    }
  }

  /// Returns a list of visible tabs/features based on user
  static List<String> getVisibleTabs(Employee user) {
    List<String> tabs = ['Home'];
    if (can(user, AppPermission.viewTeam)) tabs.add('My Team');
    if (can(user, AppPermission.approveLeave)) tabs.add('Approvals');
    tabs.add('Profile');
    return tabs;
  }
}
