import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/database/daos/favorite_dao.dart';
import 'package:flutter_catalog_app/core/errors/exceptions.dart';
import 'package:flutter_catalog_app/features/posts/data/models/favorite_dto.dart';
import 'package:flutter_catalog_app/features/posts/data/models/post_dto.dart';

abstract class FavoritesLocalDataSource {
  Stream<List<FavoriteDto>> watchFavorites();

  Future<void> toggle(PostDto post);

  Future<int> count();
}

@LazySingleton(as: FavoritesLocalDataSource)
class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  FavoritesLocalDataSourceImpl(this._dao);

  final FavoriteDao _dao;

  @override
  Stream<List<FavoriteDto>> watchFavorites() => _dao.watchAll().map(
        (rows) => [
          for (final row in rows)
            FavoriteDto(
              post: PostDto.fromRow(row.post),
              addedAt: row.createdAt,
            ),
        ],
      );

  @override
  Future<void> toggle(PostDto post) async {
    try {
      await _dao.toggle(post.toRow());
    } on Exception {
      throw const CacheException();
    }
  }

  @override
  Future<int> count() async {
    try {
      return await _dao.count();
    } on Exception {
      throw const CacheException();
    }
  }
}
