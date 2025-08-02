import 'dart:io';
import 'package:dio/dio.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../exceptions/app_exceptions.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 5000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<List<PostModel>> getPosts() async {
    try {
      final response = await _dio.get('/posts');
      return (response.data as List)
          .map((post) => PostModel.fromJson(post))
          .toList();
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      return (response.data as List)
          .map((user) => UserModel.fromJson(user))
          .toList();
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<CommentModel>> getComments(int postId) async {
    try {
      final response = await _dio.get('/posts/$postId/comments');
      return (response.data as List)
          .map((comment) => CommentModel.fromJson(comment))
          .toList();
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PostModel> createPost(PostModel post) async {
    try {
      final response = await _dio.post('/posts', data: post.toJson());
      // The API returns the created post with a new ID
      return PostModel.fromJson(response.data);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  dynamic _handleDioError(DioException dioError) {
    // Log the error for debugging

    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw FetchDataException('Connection timeout with API server');
      case DioExceptionType.badResponse:
        throw _handleStatusCode(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
      case DioExceptionType.cancel:
        throw FetchDataException('Request to API server was cancelled');
      case DioExceptionType.connectionError:
        throw FetchDataException(
          'Connection error, please check your internet.',
        );
      case DioExceptionType.badCertificate:
        throw FetchDataException('Certificate verification failed');
      case DioExceptionType.unknown:
        throw FetchDataException('Something went wrong: ${dioError.message}');
    }
  }

  dynamic _handleStatusCode(int? statusCode, dynamic responseData) {
    // Extract error message from response if available
    String errorMessage = 'Unknown error';
    if (responseData != null) {
      if (responseData is Map && responseData.containsKey('message')) {
        errorMessage = responseData['message'];
      } else if (responseData is String) {
        errorMessage = responseData;
      }
    }

    switch (statusCode) {
      case 400:
        return BadRequestException('Bad request: $errorMessage');
      case 401:
        return UnauthorisedException('Unauthorised: $errorMessage');
      case 403:
        return ForbiddenException('Access forbidden: $errorMessage');
      case 404:
        return FetchDataException('Resource not found: $errorMessage');
      case 429:
        return FetchDataException('Too many requests. Please try again later.');
      case 500:
        return FetchDataException('Internal server error: $errorMessage');
      case 502:
        return FetchDataException('Bad gateway: $errorMessage');
      case 503:
        return FetchDataException('Service unavailable: $errorMessage');
      default:
        return FetchDataException(
          'Error occurred while communicating with server with StatusCode: $statusCode. $errorMessage',
        );
    }
  }
}
