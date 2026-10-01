import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_catalog_app/core/di/injection.dart';
import 'package:flutter_catalog_app/core/observer/app_bloc_observer.dart';
import 'package:flutter_catalog_app/core/router/app_router.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_bloc.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_event.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/post_event.dart';
import 'package:flutter_catalog_app/features/users/presentation/bloc/user_bloc.dart';
import 'package:flutter_catalog_app/l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  Bloc.observer = const AppBlocObserver();
  runApp(CatalogApp());
}

class CatalogApp extends StatelessWidget {
  CatalogApp({super.key});

  final _router = getIt<AppRouter>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<PostBloc>()..add(const PostEvent.fetchPosts()),
        ),
        BlocProvider(
          lazy: false,
          create: (_) =>
              getIt<FavoritesBloc>()..add(const FavoritesEvent.started()),
        ),
        BlocProvider(create: (_) => getIt<UserBloc>()),
      ],
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        routerConfig: _router.config(),
      ),
    );
  }
}
