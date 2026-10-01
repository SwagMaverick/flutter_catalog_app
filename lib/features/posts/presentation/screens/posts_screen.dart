import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_catalog_app/core/bloc/load_status.dart';
import 'package:flutter_catalog_app/core/l10n/failure_localization.dart';
import 'package:flutter_catalog_app/core/router/app_router.gr.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/post_bloc.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/post_event.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/post_state.dart';
import 'package:flutter_catalog_app/features/posts/presentation/widgets/post_card.dart';
import 'package:flutter_catalog_app/l10n/app_localizations.dart';

@RoutePage()
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<PostBloc>().add(const PostEvent.fetchMorePosts());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: l10n.usersTitle,
            onPressed: () => context.router.push(const UsersRoute()),
          ),
          IconButton(
            icon: const Icon(Icons.star_outline),
            tooltip: l10n.favoritesTitle,
            onPressed: () => context.router.push(const FavoritesRoute()),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: _SearchField(),
        ),
      ),
      body: BlocConsumer<PostBloc, PostState>(
        listenWhen: (previous, current) =>
            current.failure != null && previous.failure != current.failure,
        listener: (context, state) {
          if (state.posts.isEmpty) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure!.localizedMessage(l10n))),
          );
        },
        builder: (context, state) => switch (state.status) {
          LoadStatus.initial ||
          LoadStatus.loading =>
            const Center(child: CircularProgressIndicator()),
          LoadStatus.failure =>
            _ErrorView(message: state.failure!.localizedMessage(l10n)),
          LoadStatus.success =>
            _PostList(state: state, controller: _scrollController),
        },
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField();

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: context.read<PostBloc>().state.query,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          prefixIcon: const Icon(Icons.search),
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) =>
            context.read<PostBloc>().add(PostEvent.searchChanged(value)),
      ),
    );
  }
}

class _PostList extends StatelessWidget {
  const _PostList({required this.state, required this.controller});

  final PostState state;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final posts = state.posts;
    return RefreshIndicator(
      onRefresh: () => context.read<PostBloc>().refresh(),
      child: posts.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(child: Text(l10n.emptyPosts)),
                ),
              ),
            )
          : ListView.builder(
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: posts.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == posts.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final post = posts[index];
                return PostCard(
                  post: post,
                  onTap: () =>
                      context.router.push(PostDetailsRoute(id: post.id)),
                );
              },
            ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  context.read<PostBloc>().add(const PostEvent.fetchPosts()),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
