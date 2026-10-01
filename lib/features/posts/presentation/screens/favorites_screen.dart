import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_catalog_app/core/router/app_router.gr.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_bloc.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_event.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_state.dart';
import 'package:flutter_catalog_app/l10n/app_localizations.dart';

@RoutePage()
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.favoritesTitle)),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state.favorites.isEmpty) {
            return Center(child: Text(l10n.favoritesEmpty));
          }
          return ListView.builder(
            itemCount: state.favorites.length,
            itemBuilder: (context, index) {
              final favorite = state.favorites[index];
              final post = favorite.post;
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  title: Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(l10n.favoriteAddedOn(favorite.addedAt)),
                  trailing: IconButton(
                    icon: const Icon(Icons.star),
                    tooltip: l10n.removeFromFavorites,
                    onPressed: () => context
                        .read<FavoritesBloc>()
                        .add(FavoritesEvent.toggled(post)),
                  ),
                  onTap: () =>
                      context.router.push(PostDetailsRoute(id: post.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
