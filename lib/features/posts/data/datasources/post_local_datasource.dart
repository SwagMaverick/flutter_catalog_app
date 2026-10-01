import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/database/daos/post_dao.dart';
import 'package:flutter_catalog_app/core/errors/exceptions.dart';
import 'package:flutter_catalog_app/features/posts/data/models/post_dto.dart';

abstract class PostLocalDataSource {
  Future<List<PostDto>> getPosts({
    required int page,
    required int limit,
    String? query,
  });

  Future<void> cachePosts(List<PostDto> posts);
}

@LazySingleton(as: PostLocalDataSource)
class PostLocalDataSourceImpl implements PostLocalDataSource {
  PostLocalDataSourceImpl(this._dao);

  final PostDao _dao;

  @override
  Future<List<PostDto>> getPosts({
    required int page,
    required int limit,
    String? query,
  }) async {
    try {
      final rows = await _dao.page(
        offset: (page - 1) * limit,
        limit: limit,
        query: query,
      );
      return [for (final row in rows) PostDto.fromRow(row)];
    } on Exception {
      throw const CacheException();
    }
  }

  @override
  Future<void> cachePosts(List<PostDto> posts) async {
    try {
      await _dao.upsertAll([for (final dto in posts) dto.toRow()]);
    } on Exception {
      throw const CacheException();
    }
  }
}
