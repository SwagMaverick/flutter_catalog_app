import 'package:dartz/dartz.dart';

import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';

abstract class PostRepository {
  Future<Either<Failure, List<Post>>> getPosts({
    required int page,
    required int limit,
    String? query,
  });
}
