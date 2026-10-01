import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/bloc/load_status.dart';
import 'package:flutter_catalog_app/features/users/domain/usecases/get_users.dart';
import 'package:flutter_catalog_app/features/users/presentation/bloc/user_event.dart';
import 'package:flutter_catalog_app/features/users/presentation/bloc/user_state.dart';

@injectable
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(this._getUsers) : super(const UserState()) {
    on<FetchUsers>(_onFetch);
    on<RefreshUsers>(_onRefresh);
  }

  final GetUsers _getUsers;
  Completer<void>? _refreshing;

  Future<void> refresh() {
    _refreshing ??= Completer<void>();
    add(const UserEvent.refreshUsers());
    return _refreshing!.future;
  }

  Future<void> _onFetch(FetchUsers event, Emitter<UserState> emit) =>
      _load(emit, showLoading: true);

  Future<void> _onRefresh(RefreshUsers event, Emitter<UserState> emit) async {
    try {
      await _load(emit, showLoading: false);
    } finally {
      _refreshing?.complete();
      _refreshing = null;
    }
  }

  Future<void> _load(Emitter<UserState> emit, {required bool showLoading}) async {
    if (showLoading) {
      emit(state.copyWith(status: LoadStatus.loading, failure: null));
    }
    final result = await _getUsers();
    result.fold(
      (failure) => emit(
        state.copyWith(status: LoadStatus.failure, failure: failure),
      ),
      (users) => emit(
        state.copyWith(status: LoadStatus.success, users: users, failure: null),
      ),
    );
  }
}
