import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import '../api_client/api_services.dart';
import '../services/storage_service.dart';
import '../utils/api_constants.dart';

// ---------------------------------------------------------------------------
// Dependency Injection / Service Locator
// ---------------------------------------------------------------------------

// 1. Setup Dio with Base URL and Interceptors
// 1. Setup Dio with Base URL and Interceptors
final Dio dio =
    Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      )
      ..httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      )
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            print(
              '🚀 API Request: ${options.method} ${options.path} (Base: ${options.baseUrl})',
            );

            // Add Token to Header
            try {
              final token = await StorageService.getToken();
              if (token != null && token.isNotEmpty) {
                final cleanToken = token.trim();
                final authHeader = cleanToken.startsWith('Bearer ')
                    ? cleanToken
                    : 'Bearer $cleanToken';
                options.headers['Authorization'] = authHeader;
                print(
                  'Interceptor - Token added: ${cleanToken.substring(0, 15)}... (Prefix checked)',
                );
              } else {
                print('Interceptor - Warning: No token found in storage.');
              }
            } catch (e) {
              print('Interceptor - Error getting token: $e');
            }

            // Add Tenant ID header (X-Tenant-ID) from stored company code if available
            try {
              final tenant = await StorageService.getCompanyCode();
              if (tenant != null && tenant.isNotEmpty) {
                options.headers['X-Tenant-ID'] = tenant.trim();
                print('Interceptor - X-Tenant-ID added: ${tenant.trim()}');
              } else {
                print('Interceptor - No tenant/companyCode found in storage.');
              }
            } catch (e) {
              print('Interceptor - Error getting company code: $e');
            }

            // Log Request
            print('Interceptor - Request URL: ${options.uri}');
            print('Interceptor - Headers: ${options.headers}');
            if (options.data != null) {
              print('Interceptor - Request Data: ${options.data}');
            }
            return handler.next(options);

          },
          onResponse: (response, handler) {
            // Check for HTML response
            final contentType = response.headers.value('content-type');
            if ((contentType != null && contentType.contains('text/html')) ||
                (response.data is String && response.data.toString().trim().startsWith('<'))) {
              print('🚨 Error: API returned HTML instead of JSON. Endpoint: ${response.requestOptions.path}');
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  type: DioExceptionType.badResponse,
                  error: 'API Error: Received HTML response (likely 404 or backend issue). Path: ${response.requestOptions.path}',
                ),
              );
            }

            print(
              '✅ API Response: ${response.statusCode} ${response.requestOptions.path}',
            );
            try {
              print('Interceptor - Response Body: ${response.data}');
            } catch (_) {}
            return handler.next(response);
          },
          onError: (error, handler) {
            print('Interceptor - Error: ${error.message}');
            print('Interceptor - Response Data: ${error.response?.data}');
            if (error.response?.statusCode == 401) {
              print('Interceptor - 401 Unauthorized');
            }
            return handler.next(error);
          },
        ),
      )
      ..options.baseUrl = ApiConstants.baseUrl; // Ensure strictly set

// 2. Create ApiServices Instance
final ApiServices apiServices = ApiServices(dio);
