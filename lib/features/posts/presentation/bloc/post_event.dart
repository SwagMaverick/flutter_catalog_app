import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_event.freezed.dart';

@freezed
sealed class PostEvent with _$PostEvent {
  const factory PostEvent.fetchPosts() = FetchPosts;
  const factory PostEvent.fetchMorePosts() = FetchMorePosts;
  const factory PostEvent.refreshPosts() = RefreshPosts;
  const factory PostEvent.searchChanged(String query) = SearchChanged;
}
