import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';
import '../models/api/profile_response.dart';

class EducationDetailsScreen extends StatelessWidget {
  final ProfileData? profileData;
  const EducationDetailsScreen({super.key, this.profileData});

  @override
  Widget build(BuildContext context) {
    if (profileData == null || profileData!.education == null) {
      return _buildEmptyState(context);
    }
    
    final edu = profileData!.education!;
    final hasData = (edu.type != null && edu.type!.isNotEmpty);

    if (!hasData) {
       return _buildEmptyState(context);
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Education Details', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
        child: Column(
          children: [
            _buildSection(
              context,
              title: 'Highest Qualification',
              icon: Icons.school_outlined,
              children: [
                _buildGridItem(context, 'Degree / Type', edu.type, icon: Icons.book_outlined, colSpan: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education Details'), 
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: const Center(child: Text('No education details found')),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16.sp, color: Theme.of(context).colorScheme.primary),
              ),
              SizedBox(width: 3.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.w),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final itemWidth = (width - 4.w) / 2;
              return Wrap(
                spacing: 4.w,
                runSpacing: 4.w,
                children: children.map((widget) {
                   if (widget is _GridItemContainer) {
                     return SizedBox(
                       width: widget.colSpan == 2 ? width : itemWidth,
                       child: widget,
                     );
                   }
                   return widget;
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String label, String? value, {IconData? icon, int colSpan = 1}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return _GridItemContainer(
      colSpan: colSpan,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: Colors.grey.shade500),
            SizedBox(width: 2.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.w),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridItemContainer extends StatelessWidget {
  final Widget child;
  final int colSpan;
  const _GridItemContainer({required this.child, this.colSpan = 1});
  
  @override
  Widget build(BuildContext context) {
    return child;
  }
}
