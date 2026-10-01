import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';

part 'favorites_event.freezed.dart';

@freezed
sealed class FavoritesEvent with _$FavoritesEvent {
  const factory FavoritesEvent.started() = FavoritesStarted;
  const factory FavoritesEvent.toggled(Post post) = FavoritesToggled;
}
