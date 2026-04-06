class FaceImageRequest {
  final List<double>? embedding;
  final String? image; // Base64 image string
  
  // Registration Fields
  final bool? consentGiven;
  final String? registrationNotes;
  final String? employeeName;

  // Verification Fields
  /// Location payload expected by backend, typically: `{ "lat": <double>, "lng": <double> }`
  final Map<String, dynamic>? location;
  final String? actionType; // e.g. 'IN', 'OUT', 'AUTO'

  FaceImageRequest({
    this.embedding,
    this.image,
    this.consentGiven,
    this.registrationNotes,
    this.employeeName,
    this.location,
    this.actionType,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    // Common
    if (embedding != null) data['faceEmbedding'] = embedding;
    if (image != null) data['image'] = image;

    // Registration
    if (consentGiven != null) data['consentGiven'] = consentGiven;
    if (registrationNotes != null) data['registrationNotes'] = registrationNotes;
    if (employeeName != null) data['employeeName'] = employeeName;

    // Verification
    if (location != null) data['location'] = location;
    if (actionType != null) data['actionType'] = actionType;

    return data;
  }
}
