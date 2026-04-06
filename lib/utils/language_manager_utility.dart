class LanguageManager {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  String get(String key) {
    // Basic mapping for common keys
    final map = {
      'personal_info': 'Personal Info',
      'profile_completion': 'Profile Completion',
      'contact_detail': 'Contact Detail',
      'employment_detail': 'Employment Detail',
      'past_experience': 'Past Experience',
      'education_details': 'Achievements & Education',
      'my_timeline': 'My Timeline',
      'shift_details': 'Shift Details',
      'attendance_face': 'Attendance Face',
      'notification_settings': 'Notification Settings',
      'nominees': 'Nominees',
      'hold_team': 'Hold Team',
    };
    return map[key] ?? key.replaceAll('_', ' ').toUpperCase();
  }
}
