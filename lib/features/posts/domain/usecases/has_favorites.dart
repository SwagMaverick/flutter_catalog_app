import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/posts/domain/repositories/favorites_repository.dart';

@injectable
class HasFavorites {
  HasFavorites(this._repository);

  final FavoritesRepository _repository;

  Future<Either<Failure, bool>> call() => _repository.hasFavorites();
}
