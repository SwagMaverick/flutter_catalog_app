import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_catalog_app/features/posts/domain/entities/post.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_bloc.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/favorites_event.dart';
import 'package:flutter_catalog_app/l10n/app_localizations.dart';

class PostCard extends StatelessWidget {
  const PostCard({required this.post, required this.onTap, super.key});

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFavorite = context.select<FavoritesBloc, bool>(
      (bloc) => bloc.state.contains(post.id),
    );
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: Icon(isFavorite ? Icons.star : Icons.star_border),
          tooltip:
              isFavorite ? l10n.removeFromFavorites : l10n.addToFavorites,
          onPressed: () => context
              .read<FavoritesBloc>()
              .add(FavoritesEvent.toggled(post)),
        ),
        onTap: onTap,
      ),
    );
  }
}
