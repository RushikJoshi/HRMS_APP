import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../models/api/profile_response.dart';

class ContactDetailsScreen extends StatelessWidget {
  final ProfileData? profileData;

  const ContactDetailsScreen({super.key, this.profileData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Details'), elevation: 0),
      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          _buildCard(
            context,
            title: 'Primary Contact',
            entries: [
              _Entry('Phone', profileData?.phone),
              _Entry('Email', profileData?.email),
              _Entry('Emergency Name', profileData?.emergencyContactName),
              _Entry('Emergency Number', profileData?.emergencyContactNumber),
            ],
          ),
          SizedBox(height: 3.w),
          _buildCard(
            context,
            title: 'Address',
            entries: [
              _Entry('Current Address', profileData?.tempAddress?.fullAddress),
              _Entry(
                'Permanent Address',
                profileData?.permAddress?.fullAddress,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required List<_Entry> entries,
  }) {
    final validEntries = entries
        .where((e) => (e.value ?? '').trim().isNotEmpty)
        .toList();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 2.w),
          if (validEntries.isEmpty)
            const Text('No details available')
          else
            ...validEntries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(top: 1.6.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 34.w,
                      child: Text(
                        entry.label,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value ?? '-',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Entry {
  final String label;
  final String? value;

  const _Entry(this.label, this.value);
}
