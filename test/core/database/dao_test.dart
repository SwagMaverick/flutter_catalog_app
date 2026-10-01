import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_catalog_app/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  const alpha = PostRow(id: 1, userId: 1, title: 'alpha', body: 'a');
  const beta = PostRow(id: 2, userId: 1, title: 'beta', body: 'b');
  const gamma = PostRow(id: 3, userId: 2, title: 'alphabet', body: 'c');

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.postDao.upsertAll([alpha, beta, gamma]);
  });

  tearDown(() => db.close());

  group('PostDao', () {
    test('pages by offset in id order', () async {
      final rows = await db.postDao.page(offset: 1, limit: 2);

      expect([for (final row in rows) row.id], [2, 3]);
    });

    test('filters by title', () async {
      final rows = await db.postDao.page(offset: 0, limit: 10, query: 'alpha');

      expect([for (final row in rows) row.id], [1, 3]);
    });

    test('upsert replaces a cached post', () async {
      await db.postDao.upsertAll([alpha.copyWith(title: 'renamed')]);

      final rows = await db.postDao.page(offset: 0, limit: 10);

      expect(rows.length, 3);
      expect(rows.first.title, 'renamed');
    });
  });

  group('FavoriteDao', () {
    test('toggle adds and removes a favorite', () async {
      await db.favoriteDao.toggle(alpha);
      expect(await db.favoriteDao.count(), 1);

      await db.favoriteDao.toggle(alpha);
      expect(await db.favoriteDao.count(), 0);
    });

    test('watchAll returns the joined post, newest first', () async {
      await db.favoriteDao.toggle(alpha);
      await db.favoriteDao.toggle(beta);

      final favorites = await db.favoriteDao.watchAll().first;

      expect([for (final f in favorites) f.post.id], [2, 1]);
    });

    test('a favorite survives a post that was never paged in', () async {
      const uncached = PostRow(id: 99, userId: 9, title: 'late', body: 'd');

      await db.favoriteDao.toggle(uncached);
      final favorites = await db.favoriteDao.watchAll().first;

      expect(favorites.single.post.title, 'late');
    });
  });
}
