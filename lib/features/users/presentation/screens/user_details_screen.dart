import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_catalog_app/features/users/domain/entities/user.dart';
import 'package:flutter_catalog_app/features/users/presentation/bloc/user_bloc.dart';
import 'package:flutter_catalog_app/l10n/app_localizations.dart';

@RoutePage()
class UserDetailsScreen extends StatelessWidget {
  const UserDetailsScreen({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.select<UserBloc, User?>((bloc) {
      for (final user in bloc.state.users) {
        if (user.id == id) return user;
      }
      return null;
    });
    return Scaffold(
      appBar: AppBar(title: Text(user?.name ?? l10n.usersTitle)),
      body: user == null
          ? Center(child: Text(l10n.errorUnknown))
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _Row(label: l10n.userEmail, value: user.email),
                _Row(label: l10n.userPhone, value: user.phone),
                _Row(label: l10n.userWebsite, value: user.website),
                _Row(label: l10n.userCity, value: user.city),
                _Row(label: l10n.userCompany, value: user.company),
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: Theme.of(context).textTheme.labelMedium),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
