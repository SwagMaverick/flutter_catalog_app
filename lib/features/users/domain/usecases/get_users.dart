import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/users/domain/entities/user.dart';
import 'package:flutter_catalog_app/features/users/domain/repositories/user_repository.dart';

@injectable
class GetUsers {
  GetUsers(this._repository);

  final UserRepository _repository;

  Future<Either<Failure, List<User>>> call() => _repository.getUsers();
}
