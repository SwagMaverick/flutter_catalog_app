import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_catalog_app/features/posts/data/models/post_dto.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/favorite.dart';

part 'favorite_dto.freezed.dart';

@freezed
abstract class FavoriteDto with _$FavoriteDto {
  const FavoriteDto._();

  const factory FavoriteDto({
    required PostDto post,
    required DateTime addedAt,
  }) = _FavoriteDto;

  Favorite toEntity() => Favorite(post: post.toEntity(), addedAt: addedAt);
}
