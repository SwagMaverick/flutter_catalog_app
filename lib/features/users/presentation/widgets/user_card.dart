import 'package:flutter/material.dart';

import 'package:flutter_catalog_app/features/users/domain/entities/user.dart';

class UserCard extends StatelessWidget {
  const UserCard({required this.user, required this.onTap, super.key});

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(child: Text(user.name.characters.first)),
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
