class Payslip {
  final String id;
  final String month; // e.g., '2026-01'
  final double grossAmount;
  final String? downloadUrl;

  Payslip({
    required this.id,
    required this.month,
    required this.grossAmount,
    this.downloadUrl,
  });

  factory Payslip.fromJson(Map<String, dynamic> json) {
    return Payslip(
      id: json['id']?.toString() ?? '',
      month: json['month']?.toString() ?? json['payMonth']?.toString() ?? '',
      grossAmount: (json['gross'] is num)
          ? (json['gross'] as num).toDouble()
          : double.tryParse('${json['gross']}') ?? 0.0,
      downloadUrl: json['downloadUrl'] as String?,
    );
  }
}
