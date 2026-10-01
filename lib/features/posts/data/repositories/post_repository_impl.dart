import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/errors/exceptions.dart';
import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/posts/data/datasources/post_local_datasource.dart';
import 'package:flutter_catalog_app/features/posts/data/datasources/post_remote_datasource.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';
import 'package:flutter_catalog_app/features/posts/domain/repositories/post_repository.dart';

@LazySingleton(as: PostRepository)
class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(this._remote, this._local);

  final PostRemoteDataSource _remote;
  final PostLocalDataSource _local;

  @override
  Future<Either<Failure, List<Post>>> getPosts({
    required int page,
    required int limit,
    String? query,
  }) async {
    try {
      final dtos = await _remote.getPosts(
        page: page,
        limit: limit,
        query: query,
      );
      await _local.cachePosts(dtos);
      return Right([for (final dto in dtos) dto.toEntity()]);
    } on CancelledException catch (e) {
      return Left(e.toFailure());
    } on AppException catch (e) {
      return _cachedPage(page: page, limit: limit, query: query, onMiss: e);
    }
  }

  Future<Either<Failure, List<Post>>> _cachedPage({
    required int page,
    required int limit,
    required String? query,
    required AppException onMiss,
  }) async {
    try {
      final dtos = await _local.getPosts(page: page, limit: limit, query: query);
      if (dtos.isEmpty) return Left(onMiss.toFailure());
      return Right([for (final dto in dtos) dto.toEntity()]);
    } on AppException {
      return Left(onMiss.toFailure());
    }
  }
}
