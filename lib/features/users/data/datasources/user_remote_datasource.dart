import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/errors/exceptions.dart';
import 'package:flutter_catalog_app/features/users/data/models/user_dto.dart';

abstract class UserRemoteDataSource {
  Future<List<UserDto>> getUsers();
}

@LazySingleton(as: UserRemoteDataSource)
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<UserDto>> getUsers() async {
    try {
      final response = await _dio.get<List<dynamic>>('/users');
      final data = response.data ?? const [];
      return data
          .map((e) => UserDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final error = e.error;
      throw error is AppException ? error : const ServerException();
    }
  }
}
