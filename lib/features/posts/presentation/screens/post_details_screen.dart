import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_bloc.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_event.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_catalog_app/l10n/app_localizations.dart';

@RoutePage()
class PostDetailsScreen extends StatelessWidget {
  const PostDetailsScreen({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Details can be opened from the favorites list, where the post is not
    // necessarily part of the currently loaded (or filtered) page.
    final listed = context.select<PostBloc, Post?>(
      (bloc) => _findIn(bloc.state.posts),
    );
    final saved = context.select<FavoritesBloc, Post?>(
      (bloc) => _findIn([for (final e in bloc.state.favorites) e.post]),
    );
    final post = listed ?? saved;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postDetailTitle(id)),
        actions: [if (post != null) _FavoriteButton(post: post)],
      ),
      body: post == null
          ? Center(child: Text(l10n.errorUnknown))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.postAuthor(post.userId),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
    );
  }

  Post? _findIn(List<Post> posts) {
    for (final post in posts) {
      if (post.id == id) return post;
    }
    return null;
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFavorite = context.select<FavoritesBloc, bool>(
      (bloc) => bloc.state.contains(post.id),
    );
    return IconButton(
      icon: Icon(isFavorite ? Icons.star : Icons.star_border),
      tooltip: isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
      onPressed: () =>
          context.read<FavoritesBloc>().add(FavoritesEvent.toggled(post)),
    );
  }
}
