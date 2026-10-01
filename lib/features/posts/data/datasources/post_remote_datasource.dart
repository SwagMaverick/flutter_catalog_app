import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/errors/exceptions.dart';
import 'package:flutter_catalog_app/features/posts/data/models/post_dto.dart';

abstract class PostRemoteDataSource {
  Future<List<PostDto>> getPosts({
    required int page,
    required int limit,
    String? query,
  });
}

@LazySingleton(as: PostRemoteDataSource)
class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  PostRemoteDataSourceImpl(this._dio);

  final Dio _dio;
  CancelToken? _searchToken;

  @override
  Future<List<PostDto>> getPosts({
    required int page,
    required int limit,
    String? query,
  }) async {
    CancelToken? token;
    if (query != null) {
      // A new query supersedes the one in flight, so drop that request instead
      // of waiting out a response nobody will read.
      _searchToken?.cancel();
      token = _searchToken = CancelToken();
    }
    try {
      final response = await _dio.get<List<dynamic>>(
        '/posts',
        queryParameters: {
          '_page': page,
          '_limit': limit,
          'title_like': ?query,
        },
        cancelToken: token,
      );
      final data = response.data ?? const [];
      return data
          .map((e) => PostDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final error = e.error;
      throw error is AppException ? error : const ServerException();
    }
  }
}
