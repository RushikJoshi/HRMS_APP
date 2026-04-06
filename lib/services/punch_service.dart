import 'package:shared_preferences/shared_preferences.dart';

class PunchService {
  static const String _punchInTimeKey = 'punch_in_time_key';
  static const String _punchInDateKey = 'punch_in_date_key';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> savePunchIn(DateTime punchTime) async {
    final timestamp = punchTime.millisecondsSinceEpoch;
    final dateStr = '${punchTime.year}-${punchTime.month}-${punchTime.day}';
    await _prefs.setInt(_punchInTimeKey, timestamp);
    await _prefs.setString(_punchInDateKey, dateStr);
  }

  DateTime? getPunchInTime() {
    final timestamp = _prefs.getInt(_punchInTimeKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  bool isAlreadyPunchedInToday() {
    final dateStr = _prefs.getString(_punchInDateKey);
    if (dateStr == null) return false;

    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';

    return dateStr == todayStr;
  }

  Future<void> clearPunchIn() async {
    await _prefs.remove(_punchInTimeKey);
    await _prefs.remove(_punchInDateKey);
  }

  int getElapsedSeconds() {
    final punchTime = getPunchInTime();
    if (punchTime == null) return 0;
    return DateTime.now().difference(punchTime).inSeconds;
  }
}
