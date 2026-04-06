class ApiConstants {

  // Base URL for the API
  static const String baseUrl = 'https://hrms.dev.gitakshmi.com/api';


  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Face Recognition Constants
  // Update this to match your TFLite model output (usually 128 or 192)
  static const int faceEmbeddingSize = 128; 
}
