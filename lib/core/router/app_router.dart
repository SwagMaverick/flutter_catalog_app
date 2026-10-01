import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/router/guards/favorites_guard.dart';

import 'app_router.gr.dart';

@AutoRouterConfig()
@lazySingleton
class AppRouter extends RootStackRouter {
  AppRouter(this._favoritesGuard);

  final FavoritesGuard _favoritesGuard;

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: PostsRoute.page, initial: true),
        AutoRoute(page: PostDetailsRoute.page),
        AutoRoute(page: FavoritesRoute.page, guards: [_favoritesGuard]),
        AutoRoute(page: UsersRoute.page),
        AutoRoute(page: UserDetailsRoute.page),
      ];
}
