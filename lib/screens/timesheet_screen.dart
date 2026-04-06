import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import '../api/api.dart';
import '../models/api/attendance/attendance_log.dart';
import '../models/api/attendance/regularization.dart';
import '../widgets/attendance_calendar.dart';

class TimesheetScreen extends StatefulWidget {
  const TimesheetScreen({super.key});

  @override
  State<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen> {
  final Api _api = Api();
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _selectedDays = [];
  
  List<AttendanceLog> _attendanceRecords = [];
  List<RegularizationRecord> _regularizations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch attendance and regularization data in parallel
      final attendanceResponse = await _api.getMyAttendance(
        month: _selectedDate.month, 
        year: _selectedDate.year
      );
      final regularizationResponse = await _api.getMyRegularizations(
        month: _selectedDate.month, 
        year: _selectedDate.year
      );

      setState(() {
        _attendanceRecords = attendanceResponse.data ?? [];
        _regularizations = regularizationResponse.data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching timesheet data: $e');
      setState(() => _isLoading = false);
    }
  }

  List<DateTime> _getPresentDays() {
    return _attendanceRecords
        .where((r) => r.status?.toLowerCase() == 'present')
        .map((r) => _parseDate(r.inTime ?? r.date))
        .where((d) => d != null)
        .cast<DateTime>()
        .toList();
  }

  List<DateTime> _getAbsentDays() {
    return _attendanceRecords
        .where((r) => r.status?.toLowerCase() == 'absent')
        .map((r) => _parseDate(r.date))
        .where((d) => d != null)
        .cast<DateTime>()
        .toList();
  }

  List<DateTime> _getPendingRegularizationDays() {
    return _regularizations
        .where((r) => r.status?.toLowerCase() == 'pending')
        .map((r) => _parseDate(r.date))
        .where((d) => d != null)
        .cast<DateTime>()
        .toList();
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.tryParse(dateStr);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Timesheet',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 16.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: const Color(0xFF1976D2), size: 16.sp),
              onPressed: () => _showRegularizationDialog(),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  // Calendar
                  AttendanceCalendar(
                    focusedDay: _selectedDate,
                    selectedDays: _selectedDays,
                    onPageChanged: (newDate) {
                      setState(() => _selectedDate = newDate);
                      _fetchData();
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        if (_selectedDays.any((d) => _isSameDay(d, selectedDay))) {
                          _selectedDays.removeWhere((d) => _isSameDay(d, selectedDay));
                        } else {
                          _selectedDays = [selectedDay];
                        }
                      });
                    },
                    presentDays: _getPresentDays(),
                    absentDays: _getAbsentDays(),
                  ),
                  SizedBox(height: 4.w),
                  
                  // Regularization Requests Section
                  if (_regularizations.isNotEmpty) ...[
                    _buildSectionHeader('Regularization Requests'),
                    SizedBox(height: 2.w),
                    ..._regularizations.map((reg) => Padding(
                          padding: EdgeInsets.only(bottom: 3.w),
                          child: _buildRegularizationCard(reg),
                        )),
                    SizedBox(height: 4.w),
                  ],

                  // Attendance Records Section
                  _buildSectionHeader('Attendance Records'),
                  SizedBox(height: 2.w),
                  if (_attendanceRecords.isEmpty)
                    _buildEmptyState()
                  else
                    ..._attendanceRecords.map((record) => Padding(
                          padding: EdgeInsets.only(bottom: 3.w),
                          child: _buildAttendanceCard(record),
                        )),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildRegularizationCard(RegularizationRecord reg) {
    Color statusColor = Colors.orange;
    if (reg.status?.toLowerCase() == 'approved') statusColor = Colors.green;
    if (reg.status?.toLowerCase() == 'rejected') statusColor = Colors.red;

    String formattedDate = 'Unknown Date';
    try {
      if (reg.date != null && reg.date!.isNotEmpty) {
        final parsedDate = DateTime.tryParse(reg.date!);
        if (parsedDate != null) {
          formattedDate = DateFormat('EEE MMM dd yyyy').format(parsedDate);
        }
      }
    } catch (_) {}

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  reg.status?.toUpperCase() ?? 'PENDING',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.w),
          Text(
            'Type: ${reg.type ?? 'N/A'}',
            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade700),
          ),
          SizedBox(height: 1.w),
          Text(
            'Reason: ${reg.reason ?? 'N/A'}',
            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade700),
          ),
          if (reg.checkIn != null || reg.checkOut != null) ...[
            SizedBox(height: 2.w),
            Row(
              children: [
                if (reg.checkIn != null)
                  Expanded(
                    child: Text(
                      'In: ${reg.checkIn}',
                      style: TextStyle(fontSize: 10.sp, color: const Color(0xFF1976D2)),
                    ),
                  ),
                if (reg.checkOut != null)
                  Expanded(
                    child: Text(
                      'Out: ${reg.checkOut}',
                      style: TextStyle(fontSize: 10.sp, color: const Color(0xFF00C853)),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceLog record) {
    String formattedDate = 'Unknown Date';
    try {
      final dateSource = record.inTime ?? record.date;
      if (dateSource != null && dateSource.isNotEmpty) {
        final parsedDate = DateTime.tryParse(dateSource);
        if (parsedDate != null) {
          formattedDate = DateFormat('EEE MMM dd yyyy').format(parsedDate);
        }
      }
    } catch (_) {}

    String checkIn = '--:--';
    if (record.inTime != null && record.inTime!.isNotEmpty) {
      try {
        final parsedCheckIn = DateTime.tryParse(record.inTime!);
        if (parsedCheckIn != null) {
          checkIn = DateFormat('HH:mm').format(parsedCheckIn);
        }
      } catch (_) {}
    }

    String checkOut = '--:--';
    if (record.outTime != null && record.outTime!.isNotEmpty) {
      try {
        final parsedCheckOut = DateTime.tryParse(record.outTime!);
        if (parsedCheckOut != null) {
          checkOut = DateFormat('HH:mm').format(parsedCheckOut);
        }
      } catch (_) {}
    }

    String workingHrs = '0.00 hrs';
    if (record.workingHours != null && record.workingHours!.isNotEmpty) {
      try {
        final hours = double.tryParse(record.workingHours!);
        if (hours != null) {
          workingHrs = '${hours.toStringAsFixed(2)} hrs';
        }
      } catch (_) {}
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 1.w,
              decoration: BoxDecoration(
                color: _getStatusColor(record.status),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        if (record.status != null)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
                            decoration: BoxDecoration(
                              color: _getStatusColor(record.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              record.status!,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: _getStatusColor(record.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 3.w),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildStatColumn('Check In', checkIn, const Color(0xFF1976D2))),
                        Expanded(child: _buildStatColumn('Check Out', checkOut, const Color(0xFF00C853))),
                        Expanded(child: _buildStatColumn("Working Hrs", workingHrs, const Color(0xFFFFA000))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, size: 40.sp, color: Colors.grey.shade400),
            SizedBox(height: 2.w),
            Text(
              'No attendance records found',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    final s = status.toLowerCase();
    if (s.contains('present')) return const Color(0xFF00C853);
    if (s.contains('absent')) return Colors.red;
    if (s.contains('half')) return Colors.orange;
    if (s.contains('leave')) return Colors.purple;
    return Colors.blue;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showRegularizationDialog() {
    final dateController = TextEditingController();
    final reasonController = TextEditingController();
    final checkInController = TextEditingController();
    final checkOutController = TextEditingController();
    String selectedType = 'MISSED_PUNCH';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Regularization'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  hintText: '2024-02-08',
                ),
              ),
              SizedBox(height: 2.w),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: ['MISSED_PUNCH', 'EARLY_OUT', 'LATE_IN', 'OTHER']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => selectedType = value!,
              ),
              SizedBox(height: 2.w),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Reason'),
                maxLines: 3,
              ),
              SizedBox(height: 2.w),
              TextField(
                controller: checkInController,
                decoration: const InputDecoration(
                  labelText: 'Check In Time (HH:mm)',
                  hintText: '10:15',
                ),
              ),
              SizedBox(height: 2.w),
              TextField(
                controller: checkOutController,
                decoration: const InputDecoration(
                  labelText: 'Check Out Time (HH:mm)',
                  hintText: '19:05',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final request = RegularizationRequest(
                date: dateController.text,
                reason: reasonController.text,
                type: selectedType,
                checkIn: checkInController.text.isNotEmpty ? checkInController.text : null,
                checkOut: checkOutController.text.isNotEmpty ? checkOutController.text : null,
              );

              try {
                await _api.submitRegularization(request);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Regularization submitted successfully')),
                );
                _fetchData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
