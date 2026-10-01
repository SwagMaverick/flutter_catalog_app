import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_catalog_app/core/bloc/load_status.dart';
import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';

part 'post_state.freezed.dart';

@freezed
abstract class PostState with _$PostState {
  const factory PostState({
    @Default(LoadStatus.initial) LoadStatus status,
    @Default([]) List<Post> posts,
    @Default('') String query,
    @Default(false) bool hasReachedMax,
    @Default(false) bool isLoadingMore,
    Failure? failure,
  }) = _PostState;
}
