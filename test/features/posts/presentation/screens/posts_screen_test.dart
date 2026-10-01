import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_catalog_app/core/bloc/load_status.dart';
import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_bloc.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_event.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_state.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/post_event.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/post_state.dart';
import 'package:flutter_catalog_app/features/posts/presentation/screens/posts_screen.dart';
import 'package:flutter_catalog_app/features/posts/presentation/widgets/post_card.dart';
import 'package:flutter_catalog_app/l10n/app_localizations.dart';

class MockPostBloc extends MockBloc<PostEvent, PostState> implements PostBloc {}

class MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {}

void main() {
  late MockPostBloc postBloc;
  late MockFavoritesBloc favoritesBloc;

  const firstPost = Post(id: 1, userId: 1, title: 'first post', body: 'first body');
  const posts = [
    firstPost,
    Post(id: 2, userId: 2, title: 'second post', body: 'second body'),
  ];

  setUp(() {
    postBloc = MockPostBloc();
    favoritesBloc = MockFavoritesBloc();
    when(() => favoritesBloc.state).thenReturn(const FavoritesState());
  });

  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<PostBloc>.value(value: postBloc),
          BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PostsScreen(),
        ),
      ),
    );
  }

  testWidgets('renders a spinner while the first page loads', (tester) async {
    when(() => postBloc.state)
        .thenReturn(const PostState(status: LoadStatus.loading));

    await pumpScreen(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(PostCard), findsNothing);
  });

  testWidgets('renders the loaded posts', (tester) async {
    when(() => postBloc.state).thenReturn(
      const PostState(status: LoadStatus.success, posts: posts),
    );

    await pumpScreen(tester);

    expect(find.byType(PostCard), findsNWidgets(2));
    expect(find.text('first post'), findsOneWidget);
    expect(find.text('second post'), findsOneWidget);
  });

  testWidgets('renders the failure message with a retry action',
      (tester) async {
    when(() => postBloc.state).thenReturn(
      const PostState(
        status: LoadStatus.failure,
        failure: NetworkFailure(),
      ),
    );

    await pumpScreen(tester);

    expect(find.byType(PostCard), findsNothing);
    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));

    verify(() => postBloc.add(const PostEvent.fetchPosts())).called(1);
  });

  testWidgets('shows a trailing spinner while the next page loads',
      (tester) async {
    when(() => postBloc.state).thenReturn(
      const PostState(
        status: LoadStatus.success,
        posts: posts,
        isLoadingMore: true,
      ),
    );

    await pumpScreen(tester);

    expect(find.byType(PostCard), findsNWidgets(2));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('toggling the star on a card reaches the favorites bloc',
      (tester) async {
    when(() => postBloc.state).thenReturn(
      const PostState(status: LoadStatus.success, posts: posts),
    );

    await pumpScreen(tester);
    await tester.tap(find.byIcon(Icons.star_border).first);

    verify(
      () => favoritesBloc.add(const FavoritesEvent.toggled(firstPost)),
    ).called(1);
  });
}
