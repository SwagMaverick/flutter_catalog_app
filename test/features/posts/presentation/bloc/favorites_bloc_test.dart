import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/favorite.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';
import 'package:flutter_catalog_app/features/posts/domain/usecases/toggle_favorite.dart';
import 'package:flutter_catalog_app/features/posts/domain/usecases/watch_favorites.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_bloc.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_event.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_state.dart';

class MockWatchFavorites extends Mock implements WatchFavorites {}

class MockToggleFavorite extends Mock implements ToggleFavorite {}

void main() {
  late MockWatchFavorites watchFavorites;
  late MockToggleFavorite toggleFavorite;

  const post = Post(id: 1, userId: 1, title: 't', body: 'b');
  final favorites = [Favorite(post: post, addedAt: DateTime(2026, 9, 1))];

  setUp(() {
    watchFavorites = MockWatchFavorites();
    toggleFavorite = MockToggleFavorite();
    when(watchFavorites.call).thenAnswer((_) => const Stream.empty());
  });

  blocTest<FavoritesBloc, FavoritesState>(
    'started mirrors the favorites stream',
    setUp: () =>
        when(watchFavorites.call).thenAnswer((_) => Stream.value(favorites)),
    build: () => FavoritesBloc(watchFavorites, toggleFavorite),
    act: (bloc) => bloc.add(const FavoritesEvent.started()),
    expect: () => [FavoritesState(favorites: favorites)],
    verify: (bloc) => expect(bloc.state.contains(post.id), isTrue),
  );

  blocTest<FavoritesBloc, FavoritesState>(
    'toggled surfaces a write failure',
    setUp: () => when(() => toggleFavorite(post))
        .thenAnswer((_) async => const Left(CacheFailure())),
    build: () => FavoritesBloc(watchFavorites, toggleFavorite),
    act: (bloc) => bloc.add(const FavoritesEvent.toggled(post)),
    expect: () => const [FavoritesState(failure: CacheFailure())],
  );

  blocTest<FavoritesBloc, FavoritesState>(
    'a successful toggle clears the previous failure',
    setUp: () =>
        when(() => toggleFavorite(post)).thenAnswer((_) async => Right(unit)),
    build: () => FavoritesBloc(watchFavorites, toggleFavorite),
    seed: () => const FavoritesState(failure: CacheFailure()),
    act: (bloc) => bloc.add(const FavoritesEvent.toggled(post)),
    expect: () => const [FavoritesState()],
  );
}
