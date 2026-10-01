import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';
import 'package:flutter_catalog_app/features/posts/domain/repositories/post_repository.dart';

@injectable
class GetPosts {
  GetPosts(this._repository);

  final PostRepository _repository;

  Future<Either<Failure, List<Post>>> call({
    required int page,
    required int limit,
    String? query,
  }) {
    return _repository.getPosts(page: page, limit: limit, query: query);
  }
}
