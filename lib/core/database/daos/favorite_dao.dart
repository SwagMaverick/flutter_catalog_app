import 'package:drift/drift.dart';

import 'package:flutter_catalog_app/core/database/app_database.dart';

part 'favorite_dao.g.dart';

typedef FavoriteWithPost = ({PostRow post, DateTime createdAt});

@DriftAccessor(tables: [Favorites, Posts])
class FavoriteDao extends DatabaseAccessor<AppDatabase> with _$FavoriteDaoMixin {
  FavoriteDao(super.db);

  Stream<List<FavoriteWithPost>> watchAll() {
    final query = select(favorites).join([
      innerJoin(posts, posts.id.equalsExp(favorites.postId)),
    ])
      ..orderBy([
        OrderingTerm.desc(favorites.createdAt),
        OrderingTerm.desc(favorites.postId),
      ]);
    return query.watch().map(
          (rows) => [
            for (final row in rows)
              (
                post: row.readTable(posts),
                createdAt: row.readTable(favorites).createdAt,
              ),
          ],
        );
  }

  Future<int> count() async {
    final total = favorites.postId.count();
    final row = await (selectOnly(favorites)..addColumns([total])).getSingle();
    return row.read(total) ?? 0;
  }

  // The favourited post is upserted alongside the row: a favorite outlives the
  // page it was loaded from, and the join in [watchAll] needs it to stay cached.
  Future<void> toggle(PostRow post) {
    return transaction(() async {
      final rows = delete(favorites)..where((t) => t.postId.equals(post.id));
      if (await rows.go() > 0) return;
      await into(posts).insertOnConflictUpdate(post);
      await into(favorites).insert(
        FavoritesCompanion.insert(
          postId: Value(post.id),
          createdAt: DateTime.now(),
        ),
      );
    });
  }
}
