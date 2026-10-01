import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';

import 'package:flutter_catalog_app/core/bloc/load_status.dart';
import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/features/posts/domain/usecases/get_posts.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/post_event.dart';
import 'package:flutter_catalog_app/features/posts/presentation/bloc/post_state.dart';

const _pageSize = 20;
const _searchDebounce = Duration(milliseconds: 400);

EventTransformer<E> _debounceRestartable<E>(Duration duration) {
  return (events, mapper) => restartable<E>()(events.debounce(duration), mapper);
}

@injectable
class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc(this._getPosts) : super(const PostState()) {
    on<FetchPosts>(_onFetch);
    on<FetchMorePosts>(_onFetchMore, transformer: droppable());
    on<RefreshPosts>(_onRefresh);
    on<SearchChanged>(
      _onSearchChanged,
      transformer: _debounceRestartable(_searchDebounce),
    );
  }

  final GetPosts _getPosts;
  Completer<void>? _refreshing;

  // A refresh usually returns the list already on screen, so the bloc emits no
  // new state; RefreshIndicator has to await the handler finishing, not a state
  // change, or its spinner never stops.
  Future<void> refresh() {
    _refreshing ??= Completer<void>();
    add(const PostEvent.refreshPosts());
    return _refreshing!.future;
  }

  Future<void> _onFetch(FetchPosts event, Emitter<PostState> emit) =>
      _loadFirstPage(emit);

  Future<void> _onSearchChanged(SearchChanged event, Emitter<PostState> emit) =>
      _loadFirstPage(emit, query: event.query.trim());

  Future<void> _onRefresh(RefreshPosts event, Emitter<PostState> emit) async {
    try {
      await _loadFirstPage(emit, showLoading: false);
    } finally {
      _refreshing?.complete();
      _refreshing = null;
    }
  }

  Future<void> _loadFirstPage(
    Emitter<PostState> emit, {
    String? query,
    bool showLoading = true,
  }) async {
    final search = query ?? state.query;
    emit(
      state.copyWith(
        status: showLoading ? LoadStatus.loading : state.status,
        query: search,
        failure: null,
      ),
    );
    final result = await _getPosts(
      page: 1,
      limit: _pageSize,
      query: search.isEmpty ? null : search,
    );
    result.fold(
      (failure) {
        if (failure is CancelledFailure) return;
        emit(state.copyWith(status: LoadStatus.failure, failure: failure));
      },
      (posts) => emit(
        state.copyWith(
          status: LoadStatus.success,
          posts: posts,
          hasReachedMax: posts.length < _pageSize,
        ),
      ),
    );
  }

  Future<void> _onFetchMore(
    FetchMorePosts event,
    Emitter<PostState> emit,
  ) async {
    if (state.status != LoadStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true, failure: null));
    final search = state.query;
    final result = await _getPosts(
      page: state.posts.length ~/ _pageSize + 1,
      limit: _pageSize,
      query: search.isEmpty ? null : search,
    );
    result.fold(
      (failure) => emit(state.copyWith(isLoadingMore: false, failure: failure)),
      (posts) => emit(
        state.copyWith(
          isLoadingMore: false,
          posts: [...state.posts, ...posts],
          hasReachedMax: posts.length < _pageSize,
        ),
      ),
    );
  }
}
