import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';
import 'package:flutter_catalog_app/features/posts/domain/repositories/post_repository.dart';
import 'package:flutter_catalog_app/features/posts/domain/usecases/get_posts.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository repository;
  late GetPosts useCase;

  const posts = [Post(id: 1, userId: 1, title: 't', body: 'b')];

  setUp(() {
    repository = MockPostRepository();
    useCase = GetPosts(repository);
  });

  test('passes paging and query through to the repository', () async {
    when(() => repository.getPosts(page: 2, limit: 20, query: 'dart'))
        .thenAnswer((_) async => const Right(posts));

    final result = await useCase(page: 2, limit: 20, query: 'dart');

    expect(result.getOrElse(() => []), posts);
    verify(() => repository.getPosts(page: 2, limit: 20, query: 'dart'))
        .called(1);
  });

  test('defaults to no query', () async {
    when(() => repository.getPosts(page: 1, limit: 20, query: null))
        .thenAnswer((_) async => const Right(posts));

    await useCase(page: 1, limit: 20);

    verify(() => repository.getPosts(page: 1, limit: 20, query: null))
        .called(1);
  });

  test('propagates a failure emitted by the repository', () async {
    when(() => repository.getPosts(page: 1, limit: 20, query: null))
        .thenAnswer((_) async => const Left(NetworkFailure()));

    final result = await useCase(page: 1, limit: 20);

    expect(result.fold((f) => f, (_) => null), isA<NetworkFailure>());
  });
}
