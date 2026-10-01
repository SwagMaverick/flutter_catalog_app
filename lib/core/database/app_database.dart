import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_catalog_app/core/database/daos/favorite_dao.dart';
import 'package:flutter_catalog_app/core/database/daos/post_dao.dart';

part 'app_database.g.dart';

@DataClassName('PostRow')
class Posts extends Table {
  IntColumn get id => integer()();
  IntColumn get userId => integer()();
  TextColumn get title => text()();
  TextColumn get body => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('FavoriteRow')
class Favorites extends Table {
  IntColumn get postId => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {postId};
}

@DriftDatabase(tables: [Posts, Favorites], daos: [PostDao, FavoriteDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'catalog'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

@module
abstract class DatabaseModule {
  @lazySingleton
  AppDatabase get database => AppDatabase();

  @lazySingleton
  PostDao postDao(AppDatabase db) => db.postDao;

  @lazySingleton
  FavoriteDao favoriteDao(AppDatabase db) => db.favoriteDao;
}
