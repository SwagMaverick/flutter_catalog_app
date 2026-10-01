import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_catalog_app/core/errors/exceptions.dart';
import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/posts/data/datasources/post_local_datasource.dart';
import 'package:flutter_catalog_app/features/posts/data/datasources/post_remote_datasource.dart';
import 'package:flutter_catalog_app/features/posts/data/models/post_dto.dart';
import 'package:flutter_catalog_app/features/posts/data/repositories/post_repository_impl.dart';

class MockRemote extends Mock implements PostRemoteDataSource {}

class MockLocal extends Mock implements PostLocalDataSource {}

void main() {
  late MockRemote remote;
  late MockLocal local;
  late PostRepositoryImpl repository;

  const dtos = [PostDto(id: 1, userId: 1, title: 't', body: 'b')];

  setUp(() {
    remote = MockRemote();
    local = MockLocal();
    repository = PostRepositoryImpl(remote, local);
    registerFallbackValue(dtos);
  });

  test('caches the page it fetched from the network', () async {
    when(() => remote.getPosts(page: 1, limit: 20, query: null))
        .thenAnswer((_) async => dtos);
    when(() => local.cachePosts(any())).thenAnswer((_) async {});

    final result = await repository.getPosts(page: 1, limit: 20);

    expect(result.getOrElse(() => []).single.id, 1);
    verify(() => local.cachePosts(dtos)).called(1);
  });

  test('falls back to the cached page when the network fails', () async {
    when(() => remote.getPosts(page: 1, limit: 20, query: null))
        .thenThrow(const NetworkException());
    when(() => local.getPosts(page: 1, limit: 20, query: null))
        .thenAnswer((_) async => dtos);

    final result = await repository.getPosts(page: 1, limit: 20);

    expect(result.getOrElse(() => []).single.id, 1);
  });

  test('returns the network failure when the cache is empty too', () async {
    when(() => remote.getPosts(page: 2, limit: 20, query: null))
        .thenThrow(const NetworkException());
    when(() => local.getPosts(page: 2, limit: 20, query: null))
        .thenAnswer((_) async => const []);

    final result = await repository.getPosts(page: 2, limit: 20);

    expect(result.fold((f) => f, (_) => null), isA<NetworkFailure>());
  });

  test('does not hit the cache when the request was cancelled', () async {
    when(() => remote.getPosts(page: 1, limit: 20, query: 'dart'))
        .thenThrow(const CancelledException());

    final result = await repository.getPosts(page: 1, limit: 20, query: 'dart');

    expect(result.fold((f) => f, (_) => null), isA<CancelledFailure>());
    verifyNever(
      () => local.getPosts(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        query: any(named: 'query'),
      ),
    );
  });
}
