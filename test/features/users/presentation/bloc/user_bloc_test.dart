import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_catalog_app/core/bloc/load_status.dart';
import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/users/domain/entities/user.dart';
import 'package:flutter_catalog_app/features/users/domain/usecases/get_users.dart';
import 'package:flutter_catalog_app/features/users/presentation/bloc/user_bloc.dart';
import 'package:flutter_catalog_app/features/users/presentation/bloc/user_event.dart';
import 'package:flutter_catalog_app/features/users/presentation/bloc/user_state.dart';

class MockGetUsers extends Mock implements GetUsers {}

void main() {
  late MockGetUsers getUsers;

  const users = [
    User(
      id: 1,
      name: 'Leanne Graham',
      username: 'Bret',
      email: 'sincere@april.biz',
      phone: '1-770-736-8031',
      website: 'hildegard.org',
      city: 'Gwenborough',
      company: 'Romaguera-Crona',
    ),
  ];

  setUp(() => getUsers = MockGetUsers());

  blocTest<UserBloc, UserState>(
    'emits [loading, success] on fetchUsers',
    setUp: () =>
        when(getUsers.call).thenAnswer((_) async => const Right(users)),
    build: () => UserBloc(getUsers),
    act: (bloc) => bloc.add(const UserEvent.fetchUsers()),
    expect: () => const [
      UserState(status: LoadStatus.loading),
      UserState(status: LoadStatus.success, users: users),
    ],
  );

  blocTest<UserBloc, UserState>(
    'emits [loading, failure] when the use case fails',
    setUp: () => when(getUsers.call)
        .thenAnswer((_) async => const Left(NetworkFailure())),
    build: () => UserBloc(getUsers),
    act: (bloc) => bloc.add(const UserEvent.fetchUsers()),
    expect: () => const [
      UserState(status: LoadStatus.loading),
      UserState(status: LoadStatus.failure, failure: NetworkFailure()),
    ],
  );

  blocTest<UserBloc, UserState>(
    'refreshUsers reloads without a loading state',
    setUp: () =>
        when(getUsers.call).thenAnswer((_) async => const Right(users)),
    build: () => UserBloc(getUsers),
    seed: () => const UserState(status: LoadStatus.success),
    act: (bloc) => bloc.add(const UserEvent.refreshUsers()),
    expect: () => const [
      UserState(status: LoadStatus.success, users: users),
    ],
  );
}
