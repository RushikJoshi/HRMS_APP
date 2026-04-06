class RegularizationRequest {
  final String date;
  final String reason;
  final String type;
  final String? checkIn;
  final String? checkOut;

  RegularizationRequest({
    required this.date,
    required this.reason,
    required this.type,
    this.checkIn,
    this.checkOut,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'reason': reason,
      'type': type,
      if (checkIn != null) 'checkIn': checkIn,
      if (checkOut != null) 'checkOut': checkOut,
    };
  }
}

class RegularizationRecord {
  final String? id;
  final String? date;
  final String? reason;
  final String? type;
  final String? checkIn;
  final String? checkOut;
  final String? status;
  final String? approvedBy;
  final String? rejectionReason;

  RegularizationRecord({
    this.id,
    this.date,
    this.reason,
    this.type,
    this.checkIn,
    this.checkOut,
    this.status,
    this.approvedBy,
    this.rejectionReason,
  });

  factory RegularizationRecord.fromJson(Map<String, dynamic> json) {
    return RegularizationRecord(
      id: json['_id'] as String?,
      date: json['date'] as String?,
      reason: json['reason'] as String?,
      type: json['type'] as String?,
      checkIn: json['checkIn'] as String?,
      checkOut: json['checkOut'] as String?,
      status: json['status'] as String?,
      approvedBy: json['approvedBy'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'date': date,
      'reason': reason,
      'type': type,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'status': status,
      'approvedBy': approvedBy,
      'rejectionReason': rejectionReason,
    };
  }
}

class RegularizationResponse {
  final bool success;
  final List<RegularizationRecord>? data;
  final String? message;

  RegularizationResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory RegularizationResponse.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return RegularizationResponse(
        success: json['success'] as bool? ?? true,
        data: json['data'] != null
            ? (json['data'] as List).map((e) => RegularizationRecord.fromJson(e)).toList()
            : null,
        message: json['message'] as String?,
      );
    } else if (json is List) {
      return RegularizationResponse(
        success: true,
        data: json.map((e) => RegularizationRecord.fromJson(e)).toList(),
      );
    }
    return RegularizationResponse(success: false);
  }
}
