import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_catalog_app/core/database/app_database.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';

part 'post_dto.freezed.dart';
part 'post_dto.g.dart';

@freezed
abstract class PostDto with _$PostDto {
  const PostDto._();

  const factory PostDto({
    required int id,
    required int userId,
    required String title,
    required String body,
  }) = _PostDto;

  factory PostDto.fromJson(Map<String, dynamic> json) => _$PostDtoFromJson(json);

  factory PostDto.fromRow(PostRow row) => PostDto(
        id: row.id,
        userId: row.userId,
        title: row.title,
        body: row.body,
      );

  factory PostDto.fromEntity(Post post) => PostDto(
        id: post.id,
        userId: post.userId,
        title: post.title,
        body: post.body,
      );

  Post toEntity() => Post(id: id, userId: userId, title: title, body: body);

  PostRow toRow() => PostRow(id: id, userId: userId, title: title, body: body);
}
