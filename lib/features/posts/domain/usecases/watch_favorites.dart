import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/features/posts/domain/entities/favorite.dart';
import 'package:flutter_catalog_app/features/posts/domain/repositories/favorites_repository.dart';

@injectable
class WatchFavorites {
  WatchFavorites(this._repository);

  final FavoritesRepository _repository;

  Stream<List<Favorite>> call() => _repository.watchFavorites();
}
