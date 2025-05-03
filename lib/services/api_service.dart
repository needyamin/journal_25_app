import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://journal_25.test/api';
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();
  bool _isInitialized = false;

  ApiService() {
    _initializeDio();
  }

  Future<void> _initializeDio() async {
    if (_isInitialized) return;
    
    _dio.options.baseUrl = baseUrl;
    
    // Add request logging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print('API Request: ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        print('API Response: ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        print('API Error: ${e.message} (${e.response?.statusCode})');
        return handler.next(e);
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          // Skip token check for public endpoints and auth endpoints
          if (options.path.startsWith('/public/') || 
              options.path == '/login' || 
              options.path == '/register' ||
              options.path == '/forgot-password' ||
              options.path == '/reset-password') {
            return handler.next(options);
          }

          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            // Add Bearer token to headers
            options.headers['Authorization'] = 'Bearer $token';
            print('Token added to request: Bearer ${token.substring(0, 10)}...');
          } else {
            print('No token found in storage');
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Authentication required',
                type: DioExceptionType.unknown,
              ),
            );
          }
        } catch (e) {
          print('Error in token handling: $e');
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Authentication error',
              type: DioExceptionType.unknown,
            ),
          );
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        print('API Error: ${e.message} (${e.response?.statusCode})');
        if (e.response?.statusCode == 401 && 
            !e.requestOptions.path.contains('/login') && 
            !e.requestOptions.path.contains('/register')) {
          print('Token expired or invalid, clearing storage');
          await _storage.delete(key: 'auth_token');
        }
        return handler.next(e);
      },
    ));
    _isInitialized = true;
  }

  // Auth endpoints (no token required)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('=== Login Attempt ===');
      print('Email: $email');
      
      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      print('=== Login Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        // Check for Laravel Sanctum token
        if (response.data['token'] != null) {
          final token = response.data['token'];
          print('Token received: ${token.substring(0, 10)}...');
          await _storage.write(key: 'auth_token', value: token);
          
          return {
            'success': true,
            'message': 'Login successful',
            'data': response.data,
          };
        } 
        // Check for Laravel Sanctum API token
        else if (response.data['access_token'] != null) {
          final token = response.data['access_token'];
          print('Access token received: ${token.substring(0, 10)}...');
          await _storage.write(key: 'auth_token', value: token);
          
          return {
            'success': true,
            'message': 'Login successful',
            'data': response.data,
          };
        }
        // Check for any error message in the response
        else if (response.data['message'] != null) {
          print('Error message in response: ${response.data['message']}');
          return {
            'success': false,
            'message': response.data['message'],
            'error': 'Login failed',
          };
        } else {
          print('Error: No token found in response');
          print('Response data: ${response.data}');
          return {
            'success': false,
            'message': 'Invalid response from server',
            'error': 'Invalid response',
          };
        }
      } else if (response.statusCode == 401) {
        print('Unauthorized: Invalid credentials');
        return {
          'success': false,
          'message': 'Invalid email or password',
          'error': 'Invalid credentials',
        };
      } else if (response.statusCode == 422) {
        final errors = response.data['errors'] ?? {};
        print('Validation errors: $errors');
        
        String errorMessage = 'Invalid input';
        if (errors['email'] != null) {
          errorMessage = errors['email'][0];
        } else if (errors['password'] != null) {
          errorMessage = errors['password'][0];
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'error': 'Validation error',
        };
      } else {
        print('Unexpected status code: ${response.statusCode}');
        print('Response data: ${response.data}');
        return {
          'success': false,
          'message': response.data['message'] ?? 'Login failed. Please try again.',
          'error': 'Unknown error',
        };
      }
    } catch (e) {
      print('=== Login Error ===');
      print('Error: $e');
      if (e is DioException) {
        print('Dio Error Type: ${e.type}');
        print('Dio Error Message: ${e.message}');
        print('Dio Error Response: ${e.response?.data}');
        
        if (e.response?.statusCode == 401) {
          return {
            'success': false,
            'message': 'Invalid email or password',
            'error': 'Invalid credentials',
          };
        } else if (e.response?.statusCode == 422) {
          final errors = e.response?.data['errors'] ?? {};
          print('Validation errors: $errors');
          
          String errorMessage = 'Invalid input';
          if (errors['email'] != null) {
            errorMessage = errors['email'][0];
          } else if (errors['password'] != null) {
            errorMessage = errors['password'][0];
          }
          
          return {
            'success': false,
            'message': errorMessage,
            'error': 'Validation error',
          };
        }
      }
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
        'error': e.toString(),
      };
    }
  }

  Future<Response> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'];
        print('Registration successful, storing token: $token');
        await _storage.write(key: 'auth_token', value: token);
      } else {
        print('Registration response missing token: ${response.data}');
      }

      return response;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      print('Checking login status');
      final token = await _storage.read(key: 'auth_token');
      print('Token status: ${token != null ? 'Present' : 'Not found'}');
      return token != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Get current token
  Future<String?> getToken() async {
    try {
      print('Retrieving token');
      final token = await _storage.read(key: 'auth_token');
      print('Token retrieved: ${token != null ? 'Present' : 'Not found'}');
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<Response> forgotPassword(String email) async {
    return _dio.post(
      '/forgot-password',
      data: {'email': email},
      options: Options(
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  Future<Response> resetPassword(String token, String email, String password) async {
    return _dio.post(
      '/reset-password',
      data: {
        'token': token,
        'email': email,
        'password': password,
        'password_confirmation': password,
      },
      options: Options(
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  // Protected endpoints (require token)
  Future<void> logout() async {
    try {
      print('Attempting logout');
      final token = await _storage.read(key: 'auth_token');
      print('Current token before logout: ${token != null ? 'Present' : 'Not found'}');
      
      await _dio.post(
        '/logout',
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );
      
      await _storage.delete(key: 'auth_token');
      print('Logged out successfully, token cleared');
    } catch (e) {
      print('Logout error: $e');
      await _storage.delete(key: 'auth_token');
      print('Token cleared after logout error');
    }
  }

  // User Profile
  Future<Response> getUserProfile() async {
    return _dio.get(
      '/v1/user',
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  Future<Response> updateUserProfile(Map<String, dynamic> data) async {
    return _dio.put(
      '/v1/user/profile',
      data: data,
      options: Options(
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  Future<Response> changePassword(String currentPassword, String newPassword) async {
    return _dio.post(
      '/v1/user/change-password',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      },
      options: Options(
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  // Public endpoints (no token required)
  Future<Response> getJournals({int page = 1, int perPage = 15}) async {
    try {
      print('Fetching journals...');
      final response = await _dio.get(
        '/public/journals',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
        options: Options(
          validateStatus: (status) => status! < 500,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );
      print('Journals response: ${response.statusCode}');
      print('Journals data: ${response.data}');
      return response;
    } catch (e) {
      print('Error fetching journals: $e');
      rethrow;
    }
  }

  Future<Response> getJournalDetails(int journalId) async {
    try {
      print('Fetching journal details for ID: $journalId');
      final response = await _dio.get(
        '/public/journals/$journalId',
        options: Options(
          validateStatus: (status) => true, // Accept any status code
          headers: {
            'Accept': 'application/json',
          },
        ),
      );
      
      print('Journal details response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Journal details data: ${response.data}');
        return response;
      } else if (response.statusCode == 500) {
        print('Journal details server error, returning mock data');
        // Return mock journal data for development
        return Response(
          data: {
            'journal_id': journalId,
            'title': 'Journal of Science & Technology',
            'description': 'This is a journal focused on science and technology research.',
            'issn': '1234-5678',
            'publisher': {
              'publisher_id': 1,
              'name': 'Academic Publishers'
            },
            'editorial_board': [
              {
                'editorial_board_id': 1,
                'name': 'Dr. Jane Smith',
                'role': 'Editor-in-Chief'
              },
              {
                'editorial_board_id': 2,
                'name': 'Dr. John Doe',
                'role': 'Associate Editor'
              }
            ],
            'recent_issues': [
              {
                'issue_id': 1,
                'issue_number': 'Volume 1, Issue 1',
                'publication_date': '2023-01-01'
              },
              {
                'issue_id': 2,
                'issue_number': 'Volume 1, Issue 2',
                'publication_date': '2023-04-01'
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/public/journals/$journalId'),
        );
      } else {
        print('Journal details error: ${response.statusCode} - ${response.statusMessage}');
        throw DioException(
          requestOptions: RequestOptions(path: '/public/journals/$journalId'),
          error: 'Failed to load journal details',
          type: DioExceptionType.badResponse,
          response: response,
        );
      }
    } catch (e) {
      print('Error fetching journal details: $e');
      rethrow;
    }
  }

  Future<Response> getArticles({
    int? journalId,
    int? issueId,
    int? authorId,
    String? keyword,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      print('Fetching articles...');
      final response = await _dio.get(
        '/public/articles',
        queryParameters: {
          if (journalId != null) 'journal_id': journalId,
          if (issueId != null) 'issue_id': issueId,
          if (authorId != null) 'author_id': authorId,
          if (keyword != null) 'keyword': keyword,
          'page': page,
          'per_page': perPage,
        },
        options: Options(
          validateStatus: (status) => status! < 500,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );
      print('Articles response: ${response.statusCode}');
      print('Articles data: ${response.data}');
      return response;
    } catch (e) {
      print('Error fetching articles: $e');
      rethrow;
    }
  }

  Future<Response> getArticleDetails(int articleId) async {
    try {
      print('Fetching article details for ID: $articleId');
      final response = await _dio.get(
        '/public/articles/$articleId',
        options: Options(
          validateStatus: (status) => true, // Accept any status code
          headers: {
            'Accept': 'application/json',
          },
        ),
      );
      
      print('Article details response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Article details data: ${response.data}');
        return response;
      } else if (response.statusCode == 500) {
        print('Article details server error, returning mock data');
        // Return mock article data for development
        return Response(
          data: {
            'article_id': articleId,
            'title': 'Advances in Machine Learning Applications',
            'abstract': 'This paper explores recent advances in machine learning applications across various domains.',
            'doi': '10.1234/abcd.123',
            'authors': [
              {
                'author_id': 1,
                'name': 'Dr. John Doe',
                'affiliation': 'University of Science'
              },
              {
                'author_id': 2,
                'name': 'Dr. Jane Smith',
                'affiliation': 'Institute of Technology'
              }
            ],
            'journal': {
              'journal_id': 1,
              'title': 'Journal of Computer Science'
            },
            'publication_date': '2023-05-15'
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/public/articles/$articleId'),
        );
      } else {
        print('Article details error: ${response.statusCode} - ${response.statusMessage}');
        throw DioException(
          requestOptions: RequestOptions(path: '/public/articles/$articleId'),
          error: 'Failed to load article details',
          type: DioExceptionType.badResponse,
          response: response,
        );
      }
    } catch (e) {
      print('Error fetching article details: $e');
      rethrow;
    }
  }

  Future<Response> getFeaturedArticles() async {
    return _dio.get(
      '/public/articles/featured',
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  Future<Response> getRecentArticles() async {
    return _dio.get(
      '/public/articles/recent',
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  // Issues
  Future<Response> getIssues({int page = 1, int perPage = 15}) async {
    return _dio.get(
      '/public/issues',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  Future<Response> getIssueDetails(int issueId) async {
    return _dio.get(
      '/public/issues/$issueId',
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  Future<Response> getRecentIssues() async {
    return _dio.get(
      '/public/issues/recent',
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  // Editorial Board
  Future<Response> getEditorialBoard() async {
    return _dio.get(
      '/public/editorial-board',
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  // Keywords
  Future<Response> getPopularKeywords() async {
    return _dio.get(
      '/public/keywords/popular',
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  // Search
  Future<Response> search(String query) async {
    return _dio.get(
      '/public/search',
      queryParameters: {'query': query},
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  // File download (requires token)
  Future<Response> downloadArticleFile(int articleId, String fileType) async {
    return _dio.get(
      '/download/article/$articleId/$fileType',
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  // Notifications
  Future<Response> getNotifications() async {
    return _dio.get(
      '/v1/notifications',
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  Future<Response> markNotificationsAsRead() async {
    return _dio.post(
      '/v1/notifications/mark-read',
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  Future<Response> getUnreadNotificationsCount() async {
    return _dio.get(
      '/v1/notifications/unread-count',
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  void _handleTokenExpiration() {
    // Navigate to login screen
    // Clear any sensitive data
    // Show appropriate message to user
  }
} 