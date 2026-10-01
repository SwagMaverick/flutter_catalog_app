import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/favorite.dart';

part 'favorites_state.freezed.dart';

@freezed
abstract class FavoritesState with _$FavoritesState {
  const FavoritesState._();

  const factory FavoritesState({
    @Default([]) List<Favorite> favorites,
    Failure? failure,
  }) = _FavoritesState;

  bool contains(int postId) => favorites.any((e) => e.post.id == postId);
}
