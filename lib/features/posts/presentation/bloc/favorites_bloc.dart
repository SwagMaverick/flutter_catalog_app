import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/features/posts/domain/entities/favorite.dart';
import 'package:flutter_catalog_app/features/posts/domain/usecases/toggle_favorite.dart';
import 'package:flutter_catalog_app/features/posts/domain/usecases/watch_favorites.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_event.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_state.dart';

@injectable
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc(this._watchFavorites, this._toggleFavorite)
      : super(const FavoritesState()) {
    on<FavoritesStarted>(_onStarted, transformer: restartable());
    on<FavoritesToggled>(_onToggled);
  }

  final WatchFavorites _watchFavorites;
  final ToggleFavorite _toggleFavorite;

  Future<void> _onStarted(
    FavoritesStarted event,
    Emitter<FavoritesState> emit,
  ) {
    return emit.forEach<List<Favorite>>(
      _watchFavorites(),
      onData: (favorites) => state.copyWith(favorites: favorites),
    );
  }

  // The list itself comes back through the watch stream, so a successful toggle
  // only has to clear the previous write failure.
  Future<void> _onToggled(
    FavoritesToggled event,
    Emitter<FavoritesState> emit,
  ) async {
    final result = await _toggleFavorite(event.post);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (_) => emit(state.copyWith(failure: null)),
    );
  }
}
