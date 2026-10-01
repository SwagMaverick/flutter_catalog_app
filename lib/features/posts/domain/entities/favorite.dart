import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';

part 'favorite.freezed.dart';

@freezed
abstract class Favorite with _$Favorite {
  const factory Favorite({required Post post, required DateTime addedAt}) =
      _Favorite;
}
