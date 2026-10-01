import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/errors/exceptions.dart';
import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/users/data/datasources/user_remote_datasource.dart';
import 'package:flutter_catalog_app/features/users/domain/entities/user.dart';
import 'package:flutter_catalog_app/features/users/domain/repositories/user_repository.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._remote);

  final UserRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<User>>> getUsers() async {
    try {
      final dtos = await _remote.getUsers();
      return Right([for (final dto in dtos) dto.toEntity()]);
    } on AppException catch (e) {
      return Left(e.toFailure());
    }
  }
}
