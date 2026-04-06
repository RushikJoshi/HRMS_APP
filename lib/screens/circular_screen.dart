import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/circular/circular_bloc.dart';
import '../bloc/circular/circular_event.dart';
import '../bloc/circular/circular_state.dart';
import '../utils/app_icons.dart';

enum CircularStatus {
  newStatus('New', Colors.blue),
  important('Important', Colors.orange);

  final String label;
  final Color color;
  const CircularStatus(this.label, this.color);
}

class Circular {
  final String id;
  final String title;
  final DateTime date;
  final String description;
  final String uploadedBy;
  final CircularStatus? status;
  final List<String> attachments;
  final bool isRead;
  final String category;

  Circular({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.uploadedBy,
    this.status,
    this.attachments = const [],
    this.isRead = false,
    this.category = 'General',
  });
}

class CircularScreen extends StatelessWidget {
  const CircularScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _CircularScreenContent();
  }
}

class _CircularScreenContent extends StatelessWidget {
  const _CircularScreenContent();

  void _showFilterBottomSheet(BuildContext context) {
    final bloc = context.read<CircularBloc>();
    final categories = ['All', 'Holiday', 'Meeting', 'Policy', 'Event'];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) { // Use a distinct context name for clarity
        return BlocProvider.value(
          value: bloc,
          child: BlocBuilder<CircularBloc, CircularState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Filter by Category',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...categories.map((category) {
                      return ListTile(
                        title: Text(category),
                        leading: Radio<String>(
                          value: category,
                          groupValue: state.selectedCategory ?? 'All',
                          onChanged: (value) {
                            bloc.add(CircularCategoryFilterChanged(value == 'All' ? null : value));
                            Navigator.pop(context);
                          },
                        ),
                        onTap: () {
                          bloc.add(CircularCategoryFilterChanged(category == 'All' ? null : category));
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Circulars'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(AppIcons.filterOutlined),
            onPressed: () => _showFilterBottomSheet(context),
          ),
          BlocBuilder<CircularBloc, CircularState>(
            builder: (context, state) {
              final unreadCount = state.allCirculars.where((c) => !c.isRead).length;
              return Stack(
            children: [
              IconButton(
                icon: const Icon(AppIcons.notifications),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$unreadCount unread circulars available'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
                  if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                          '$unreadCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CircularBloc, CircularState>(
        builder: (context, state) {
          final bloc = context.read<CircularBloc>();
          
          return Column(
            children: [
              _buildSearchBar(context, bloc, state),
              Expanded(
                child: _buildBodyContent(context, bloc, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, CircularBloc bloc, CircularState state) {
    if (state.status == CircularLoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == CircularLoadStatus.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'Failed to load circulars',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                bloc.add(const CircularLoad());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.filteredCirculars.isEmpty) {
      return _buildEmptyState();
    }

    final grouped = state.groupedCirculars;
    final orderedGroups = ['Today', 'This Week', 'Previous Month', 'Older'];
    
    return _buildCircularList(context, bloc, grouped, orderedGroups);
  }

  Widget _buildSearchBar(BuildContext context, CircularBloc bloc, CircularState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        onChanged: (value) {
          bloc.add(CircularSearchChanged(value));
        },
        decoration: InputDecoration(
          hintText: 'Search circulars...',
          prefixIcon: const Icon(AppIcons.search),
          suffixIcon: state.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(AppIcons.clear),
                  onPressed: () {
                    bloc.add(const CircularSearchChanged(''));
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.inbox,
              size: 50.sp,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
               'No circulars found',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
               'Try adjusting your search or filter',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularList(BuildContext context, CircularBloc bloc, Map<String, List<Circular>> grouped, List<String> orderedGroups) {
    final groupKeys = orderedGroups.where((key) => grouped.containsKey(key)).toList();

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: groupKeys.length,
      itemBuilder: (context, index) {
        final groupKey = groupKeys[index];
        final circulars = grouped[groupKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupHeader(context, groupKey, circulars.length),
            const SizedBox(height: 12),
            ...circulars.map((circular) => _buildCircularCard(context, bloc, circular)),
            if (index < grouped.length - 1) const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildGroupHeader(BuildContext context, String title, int count) {
    IconData icon;
    switch (title) {
      case 'Today':
        icon = AppIcons.localFireDepartment;
        break;
      case 'This Week':
        icon = AppIcons.calendarToday;
        break;
      case 'Previous Month':
        icon = AppIcons.calendarMonth;
        break;
      default:
        icon = AppIcons.history;
    }

    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
            title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count ${count == 1 ? 'Notice' : 'Notices'}',
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularCard(BuildContext context, CircularBloc bloc, Circular circular) {
    return InkWell(
      onTap: () {
        bloc.add(CircularMarkAsRead(circular.id));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CircularDetailScreen(circular: circular),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: circular.isRead ? Colors.grey.shade200 : Colors.blue.shade200,
            width: circular.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        circular.title,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: circular.isRead ? FontWeight.w500 : FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
            Row(
              children: [
                          Icon(AppIcons.personOutlined, size: 11.sp, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            circular.uploadedBy,
                            style: TextStyle(
                              fontSize: 9.sp,
                  color: Colors.grey.shade600,
                ),
                          ),
                          const SizedBox(width: 12),
                          Icon(AppIcons.calendarToday, size: 11.sp, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(circular.date),
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (circular.status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: circular.status!.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      circular.status!.label,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: circular.status!.color,
                      ),
                    ),
                  ),
                if (!circular.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            if (circular.description.isNotEmpty) ...[
              const SizedBox(height: 12),
            Text(
                circular.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
            if (circular.attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: circular.attachments.map((attachment) {
                  return Chip(
                    label: Text(attachment),
                    avatar: Icon(AppIcons.attachFile, size: 12.sp),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CircularDetailScreen extends StatelessWidget {
  final Circular circular;

  const CircularDetailScreen({super.key, required this.circular});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circular Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              circular.title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(AppIcons.personOutlined, size: 12.sp, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  circular.uploadedBy,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(AppIcons.calendarToday, size: 12.sp, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(circular.date),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              circular.description,
              style: TextStyle(fontSize: 12.sp, height: 1.5),
            ),
            if (circular.attachments.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Attachments',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...circular.attachments.map((attachment) {
                return ListTile(
                  leading: const Icon(AppIcons.attachFile),
                  title: Text(attachment),
                  trailing: const Icon(AppIcons.download),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloading $attachment...')),
                    );
                  },
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
