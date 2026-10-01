import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_catalog_app/core/bloc/load_status.dart';
import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';
import 'package:flutter_catalog_app/features/posts/domain/usecases/get_posts.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/post_event.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/post_state.dart';

class MockGetPosts extends Mock implements GetPosts {}

List<Post> buildPosts(int count, {int from = 1}) => [
      for (var i = 0; i < count; i++)
        Post(id: from + i, userId: 1, title: 't${from + i}', body: 'b'),
    ];

void main() {
  late MockGetPosts getPosts;

  void stubPage({required int page, String? query, required List<Post> posts}) {
    when(() => getPosts(page: page, limit: 20, query: query))
        .thenAnswer((_) async => Right(posts));
  }

  setUp(() => getPosts = MockGetPosts());

  group('fetchPosts', () {
    blocTest<PostBloc, PostState>(
      'emits [loading, success] with a full first page',
      setUp: () => stubPage(page: 1, posts: buildPosts(20)),
      build: () => PostBloc(getPosts),
      act: (bloc) => bloc.add(const PostEvent.fetchPosts()),
      expect: () => [
        const PostState(status: LoadStatus.loading),
        PostState(status: LoadStatus.success, posts: buildPosts(20)),
      ],
    );

    blocTest<PostBloc, PostState>(
      'marks hasReachedMax when the first page is short',
      setUp: () => stubPage(page: 1, posts: buildPosts(7)),
      build: () => PostBloc(getPosts),
      act: (bloc) => bloc.add(const PostEvent.fetchPosts()),
      skip: 1,
      expect: () => [
        PostState(
          status: LoadStatus.success,
          posts: buildPosts(7),
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<PostBloc, PostState>(
      'emits [loading, failure] when the use case fails',
      setUp: () => when(() => getPosts(page: 1, limit: 20, query: null))
          .thenAnswer((_) async => const Left(ServerFailure())),
      build: () => PostBloc(getPosts),
      act: (bloc) => bloc.add(const PostEvent.fetchPosts()),
      expect: () => const [
        PostState(status: LoadStatus.loading),
        PostState(status: LoadStatus.failure, failure: ServerFailure()),
      ],
    );
  });

  group('fetchMorePosts', () {
    blocTest<PostBloc, PostState>(
      'appends the next page and stops at the last one',
      setUp: () => stubPage(page: 2, posts: buildPosts(6, from: 21)),
      build: () => PostBloc(getPosts),
      seed: () => PostState(
        status: LoadStatus.success,
        posts: buildPosts(20),
      ),
      act: (bloc) => bloc.add(const PostEvent.fetchMorePosts()),
      expect: () => [
        PostState(
          status: LoadStatus.success,
          posts: buildPosts(20),
          isLoadingMore: true,
        ),
        PostState(
          status: LoadStatus.success,
          posts: [...buildPosts(20), ...buildPosts(6, from: 21)],
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<PostBloc, PostState>(
      'is ignored once the last page was reached',
      build: () => PostBloc(getPosts),
      seed: () => PostState(
        status: LoadStatus.success,
        posts: buildPosts(5),
        hasReachedMax: true,
      ),
      act: (bloc) => bloc.add(const PostEvent.fetchMorePosts()),
      expect: () => const <PostState>[],
      verify: (_) => verifyNever(
        () => getPosts(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          query: any(named: 'query'),
        ),
      ),
    );

    blocTest<PostBloc, PostState>(
      'keeps the loaded posts when the next page fails',
      setUp: () => when(() => getPosts(page: 2, limit: 20, query: null))
          .thenAnswer((_) async => const Left(TimeoutFailure())),
      build: () => PostBloc(getPosts),
      seed: () => PostState(status: LoadStatus.success, posts: buildPosts(20)),
      skip: 1,
      act: (bloc) => bloc.add(const PostEvent.fetchMorePosts()),
      expect: () => [
        PostState(
          status: LoadStatus.success,
          posts: buildPosts(20),
          failure: const TimeoutFailure(),
        ),
      ],
    );
  });

  group('searchChanged', () {
    blocTest<PostBloc, PostState>(
      'debounces typing and only runs the last query',
      setUp: () {
        stubPage(page: 1, query: 'da', posts: buildPosts(1));
        stubPage(page: 1, query: 'dart', posts: buildPosts(2));
      },
      build: () => PostBloc(getPosts),
      act: (bloc) async {
        bloc.add(const PostEvent.searchChanged('da'));
        await Future<void>.delayed(const Duration(milliseconds: 120));
        bloc.add(const PostEvent.searchChanged('dart'));
      },
      wait: const Duration(milliseconds: 700),
      verify: (bloc) {
        verifyNever(() => getPosts(page: 1, limit: 20, query: 'da'));
        verify(() => getPosts(page: 1, limit: 20, query: 'dart')).called(1);
        expect(bloc.state.query, 'dart');
        expect(bloc.state.posts, buildPosts(2));
      },
    );

    blocTest<PostBloc, PostState>(
      'an empty query goes back to the unfiltered list',
      setUp: () => stubPage(page: 1, posts: buildPosts(20)),
      build: () => PostBloc(getPosts),
      seed: () => PostState(
        status: LoadStatus.success,
        posts: buildPosts(2),
        query: 'dart',
      ),
      act: (bloc) => bloc.add(const PostEvent.searchChanged('  ')),
      wait: const Duration(milliseconds: 700),
      verify: (bloc) {
        verify(() => getPosts(page: 1, limit: 20, query: null)).called(1);
        expect(bloc.state.query, '');
      },
    );

    blocTest<PostBloc, PostState>(
      'a cancelled request leaves the state untouched',
      setUp: () => when(() => getPosts(page: 1, limit: 20, query: 'dart'))
          .thenAnswer((_) async => const Left(CancelledFailure())),
      build: () => PostBloc(getPosts),
      act: (bloc) => bloc.add(const PostEvent.searchChanged('dart')),
      wait: const Duration(milliseconds: 700),
      expect: () => const [
        PostState(status: LoadStatus.loading, query: 'dart'),
      ],
    );
  });

  test('refresh() completes even when the list comes back unchanged', () async {
    stubPage(page: 1, posts: buildPosts(20));
    final bloc = PostBloc(getPosts);
    addTearDown(bloc.close);

    bloc.add(const PostEvent.fetchPosts());
    await bloc.stream.firstWhere((s) => s.status == LoadStatus.success);

    await bloc.refresh().timeout(const Duration(seconds: 1));

    expect(bloc.state.posts, buildPosts(20));
  });
}
