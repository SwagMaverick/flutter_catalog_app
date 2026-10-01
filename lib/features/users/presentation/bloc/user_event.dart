import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_event.freezed.dart';

@freezed
sealed class UserEvent with _$UserEvent {
  const factory UserEvent.fetchUsers() = FetchUsers;
  const factory UserEvent.refreshUsers() = RefreshUsers;
}
