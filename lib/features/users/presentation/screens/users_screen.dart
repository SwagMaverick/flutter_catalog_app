import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_catalog_app/core/bloc/load_status.dart';
import 'package:flutter_catalog_app/core/l10n/failure_localization.dart';
import 'package:flutter_catalog_app/core/router/app_router.gr.dart';
import 'package:flutter_catalog_app/features/users/domain/entities/user.dart';
import 'package:flutter_catalog_app/features/users/presentation/bloc/user_bloc.dart';
import 'package:flutter_catalog_app/features/users/presentation/bloc/user_event.dart';
import 'package:flutter_catalog_app/features/users/presentation/bloc/user_state.dart';
import 'package:flutter_catalog_app/features/users/presentation/widgets/user_card.dart';
import 'package:flutter_catalog_app/l10n/app_localizations.dart';

@RoutePage()
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<UserBloc>();
    if (bloc.state.status == LoadStatus.initial) {
      bloc.add(const UserEvent.fetchUsers());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.usersTitle)),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) => switch (state.status) {
          LoadStatus.initial ||
          LoadStatus.loading =>
            const Center(child: CircularProgressIndicator()),
          LoadStatus.failure =>
            _ErrorView(message: state.failure!.localizedMessage(l10n)),
          LoadStatus.success => _UserList(users: state.users),
        },
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList({required this.users});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<UserBloc>().refresh(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return UserCard(
            user: user,
            onTap: () => context.router.push(UserDetailsRoute(id: user.id)),
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
                  context.read<UserBloc>().add(const UserEvent.fetchUsers()),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
