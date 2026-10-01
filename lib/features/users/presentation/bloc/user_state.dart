import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:flutter_catalog_app/core/bloc/load_status.dart';
import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/users/domain/entities/user.dart';

part 'user_state.freezed.dart';

@freezed
abstract class UserState with _$UserState {
  const factory UserState({
    @Default(LoadStatus.initial) LoadStatus status,
    @Default([]) List<User> users,
    Failure? failure,
  }) = _UserState;
}
