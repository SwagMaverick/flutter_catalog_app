import 'package:drift/drift.dart';

import 'package:flutter_catalog_app/core/database/app_database.dart';

part 'post_dao.g.dart';

@DriftAccessor(tables: [Posts])
class PostDao extends DatabaseAccessor<AppDatabase> with _$PostDaoMixin {
  PostDao(super.db);

  Future<List<PostRow>> page({
    required int offset,
    required int limit,
    String? query,
  }) {
    final statement = select(posts)
      ..orderBy([(t) => OrderingTerm(expression: t.id)])
      ..limit(limit, offset: offset);
    if (query != null) {
      statement.where((t) => t.title.like('%$query%'));
    }
    return statement.get();
  }

  Future<void> upsertAll(List<PostRow> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(posts, rows));
}
