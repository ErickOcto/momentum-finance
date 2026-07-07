import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

// Represents error failures in the data layer
class Failure {
  final String message;
  final int? statusCode;
  Failure(this.message, {this.statusCode});

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode)';
}

// Dio wrapper handling clean architecture Error Either flow
class DioClient {
  final Dio _dio;

  DioClient({String? baseUrl})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? 'http://localhost:8080',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  Future<Either<Failure, Response<T>>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return Either.right(response);
    } on DioException catch (e) {
      return Either.left(_handleDioError(e));
    } catch (e) {
      return Either.left(Failure('Unexpected error: $e'));
    }
  }

  Future<Either<Failure, Response<T>>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Either.right(response);
    } on DioException catch (e) {
      return Either.left(_handleDioError(e));
    } catch (e) {
      return Either.left(Failure('Unexpected error: $e'));
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Failure('Connection timeout with API server');
      case DioExceptionType.sendTimeout:
        return Failure('Send timeout in connection with API server');
      case DioExceptionType.receiveTimeout:
        return Failure('Receive timeout in connection with API server');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String message = 'Received invalid status code: $statusCode';
        if (data is Map && data.containsKey('error')) {
          message = data['error'].toString();
        } else if (data is Map && data.containsKey('message')) {
          message = data['message'].toString();
        }
        return Failure(message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return Failure('Request to API server was cancelled');
      case DioExceptionType.connectionError:
        return Failure('No internet connection');
      default:
        return Failure('Unexpected error occurred');
    }
  }
}
