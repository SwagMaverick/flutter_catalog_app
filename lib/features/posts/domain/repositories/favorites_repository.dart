import 'package:dartz/dartz.dart';

import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/favorite.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';

abstract class FavoritesRepository {
  Stream<List<Favorite>> watchFavorites();

  Future<Either<Failure, Unit>> toggle(Post post);

  Future<Either<Failure, bool>> hasFavorites();
}
