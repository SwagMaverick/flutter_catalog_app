import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/router/app_router.gr.dart';
import 'package:flutter_catalog_app/features/posts/domain/usecases/has_favorites.dart';

@lazySingleton
class FavoritesGuard extends AutoRouteGuard {
  FavoritesGuard(this._hasFavorites);

  final HasFavorites _hasFavorites;

  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final result = await _hasFavorites();
    if (result.getOrElse(() => false)) {
      resolver.next();
      return;
    }
    // The screen is also reachable by deep link, so send the user to the list
    // instead of resolving into an empty stack.
    unawaited(router.navigate(const PostsRoute()));
    resolver.next(false);
  }
}
