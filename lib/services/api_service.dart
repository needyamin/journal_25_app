import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://journal_25.test/api';
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          await _storage.delete(key: 'auth_token');
        }
        return handler.next(e);
      },
    ));
  }

  // Auth endpoints
  Future<Response> login(String email, String password) async {
    return _dio.post(
      '/login',
      data: {
        'email': email,
        'password': password,
      },
      options: Options(
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  Future<Response> register(String name, String email, String password) async {
    return _dio.post(
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
  }

  Future<Response> logout() async {
    return _dio.post(
      '/logout',
      options: Options(
        contentType: Headers.jsonContentType,
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  // Journal endpoints
  Future<Response> getJournals({int page = 1, int perPage = 15}) async {
    return _dio.get(
      '/public/journals',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  Future<Response> getJournalDetails(int journalId) async {
    return _dio.get(
      '/public/journals/$journalId',
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  // Article endpoints
  Future<Response> getArticles({
    int? journalId,
    int? issueId,
    int? authorId,
    String? keyword,
    int page = 1,
    int perPage = 15,
  }) async {
    return _dio.get(
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
      ),
    );
  }

  Future<Response> getArticleDetails(int articleId) async {
    return _dio.get(
      '/public/articles/$articleId',
      options: Options(
        validateStatus: (status) => status! < 500,
      ),
    );
  }

  // Protected endpoints
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

  // File download
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
} 