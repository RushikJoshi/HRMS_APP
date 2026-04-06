class CircularResponse {
  final bool success;
  final String message;
  final List<CircularItem> data;

  CircularResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CircularResponse.fromJson(Map<String, dynamic> json) {
    // Check for standard wrapper
    if (json.containsKey('data')) {
      return CircularResponse(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? '',
        data: (json['data'] as List<dynamic>?)
                ?.map((e) => CircularItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    }
    
    // Check for "notifications" key (unwrapped response)
    if (json.containsKey('notifications')) {
      return CircularResponse(
        success: true, // Treat as success if we have the list
        message: 'Notifications loaded',
        data: (json['notifications'] as List<dynamic>?)
                ?.map((e) => CircularItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
    }

    // Default fallback
    return CircularResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'CircularResponse(success: $success, message: "$message", data: ${data.length} items)';
  }
}

class CircularItem {
  final String? id;
  final String? title;
  final String? description;
  final String? createdAt;
  final String? createdBy;
  final String? category;
  final bool isRead;
  final List<String>? attachments;
  final String? status; // e.g., 'New', 'Important'

  CircularItem({
    this.id,
    this.title,
    this.description,
    this.createdAt,
    this.createdBy,
    this.category,
    this.isRead = false,
    this.attachments,
    this.status,
  });

  factory CircularItem.fromJson(Map<String, dynamic> json) {
    return CircularItem(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String?,
      createdBy: json['created_by'] as String?,
      category: json['category'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [], // Ensure list is not null and elements are strings
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'created_at': createdAt,
      'created_by': createdBy,
      'category': category,
      'isRead': isRead,
      'attachments': attachments,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'CircularItem(id: $id, title: "$title", isRead: $isRead)';
  }
}
