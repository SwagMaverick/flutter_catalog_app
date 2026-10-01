import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/errors/exceptions.dart';
import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/posts/data/datasources/favorites_local_datasource.dart';
import 'package:flutter_catalog_app/features/posts/data/models/post_dto.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/favorite.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';
import 'package:flutter_catalog_app/features/posts/domain/repositories/favorites_repository.dart';

@LazySingleton(as: FavoritesRepository)
class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._local);

  final FavoritesLocalDataSource _local;

  @override
  Stream<List<Favorite>> watchFavorites() {
    return _local.watchFavorites().map(
          (dtos) => [for (final dto in dtos) dto.toEntity()],
        );
  }

  @override
  Future<Either<Failure, Unit>> toggle(Post post) async {
    try {
      await _local.toggle(PostDto.fromEntity(post));
      return const Right(unit);
    } on AppException catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> hasFavorites() async {
    try {
      return Right(await _local.count() > 0);
    } on AppException catch (e) {
      return Left(e.toFailure());
    }
  }
}
