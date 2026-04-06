import 'package:flutter/material.dart';

enum AttendanceHistoryStatus {
  present('Present', Colors.green),
  absent('Absent', Colors.red),
  halfDay('Half Day', Colors.orange),
  breakTaken('Break Taken', Colors.blue);

  final String label;
  final Color color;
  const AttendanceHistoryStatus(this.label, this.color);
}

class AttendanceRecord {
  final DateTime date;
  final DateTime? punchInTime;
  final DateTime? punchOutTime;
  final AttendanceHistoryStatus status;
  final int breakCount;
  final int breakDurationMinutes;

  AttendanceRecord({
    required this.date,
    this.punchInTime,
    this.punchOutTime,
    required this.status,
    this.breakCount = 0,
    this.breakDurationMinutes = 0,
  });

  Duration? get totalDuration {
    if (punchInTime != null && punchOutTime != null) {
      return punchOutTime!.difference(punchInTime!);
    }
    return null;
  }

  double get workingHours {
    if (totalDuration != null) {
      return totalDuration!.inMinutes / 60.0;
    }
    return 0.0;
  }

  String get formattedDuration {
    if (totalDuration != null) {
      final hours = totalDuration!.inHours;
      final minutes = totalDuration!.inMinutes % 60;
      return '${hours}h ${minutes}m';
    }
    return 'N/A';
  }
}

// Singleton class to manage attendance records
class AttendanceService extends ChangeNotifier {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal() {
    _initDummyData();
  }

  void _initDummyData() {
    final now = DateTime.now();
    _records.addAll([
      AttendanceRecord(
        date: now,
        punchInTime: DateTime(now.year, now.month, now.day, 9, 30),
        status: AttendanceHistoryStatus.present,
      ),
      AttendanceRecord(
        date: now.subtract(const Duration(days: 1)),
        punchInTime: DateTime(now.year, now.month, now.day - 1, 9, 15),
        punchOutTime: DateTime(now.year, now.month, now.day - 1, 18, 15),
        status: AttendanceHistoryStatus.present,
      ),
      AttendanceRecord(
        date: now.subtract(const Duration(days: 2)),
        punchInTime: DateTime(now.year, now.month, now.day - 2, 9, 0),
        punchOutTime: DateTime(now.year, now.month, now.day - 2, 17, 30),
        status: AttendanceHistoryStatus.present,
      ),
      AttendanceRecord(
        date: now.subtract(const Duration(days: 3)),
        punchInTime: DateTime(now.year, now.month, now.day - 3, 9, 10),
        punchOutTime: DateTime(now.year, now.month, now.day - 3, 18, 0),
        status: AttendanceHistoryStatus.present,
      ),
       AttendanceRecord(
        date: now.subtract(const Duration(days: 4)),
        punchInTime: DateTime(now.year, now.month, now.day - 4, 9, 05),
        punchOutTime: DateTime(now.year, now.month, now.day - 4, 18, 05),
        status: AttendanceHistoryStatus.present,
      ),
      AttendanceRecord(
        date: now.subtract(const Duration(days: 5)),
        punchInTime: DateTime(now.year, now.month, now.day - 5, 9, 20),
        punchOutTime: DateTime(now.year, now.month, now.day - 5, 17, 45),
        status: AttendanceHistoryStatus.present,
      ),
    ]);
  }

  final List<AttendanceRecord> _records = [];

  List<AttendanceRecord> get allRecords => List.unmodifiable(_records);

  void addRecord(AttendanceRecord record) {
    // Remove existing record for the same date if any
    _records.removeWhere(
      (r) =>
          r.date.year == record.date.year &&
          r.date.month == record.date.month &&
          r.date.day == record.date.day,
    );
    _records.add(record);
    _records.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  List<AttendanceRecord> getRecordsForMonth(DateTime month) {
    return _records
        .where(
          (record) =>
              record.date.year == month.year &&
              record.date.month == month.month,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void clearRecords() {
    _records.clear();
    notifyListeners();
  }
}
