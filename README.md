# flutter_catalog_app

Posts and users catalog on the [JSONPlaceholder](https://jsonplaceholder.typicode.com) API:
paginated posts with debounced search and favorites, plus a users directory. English and Russian.

## Stack

Dio · flutter_bloc · bloc_concurrency · freezed · json_serializable · get_it + injectable ·
auto_route · drift · intl · dartz · mocktail · bloc_test

Feature-first layout under `lib/features/{posts,users}` with `data` / `domain` / `presentation`,
shared `core`.

## Run

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Codegen

`freezed`, `json_serializable`, `drift`, `injectable`, and `auto_route` are code-generated and
not committed. Regenerate after changing any annotated class:

```
dart run build_runner build --delete-conflicting-outputs
```

Localizations are generated from `lib/l10n/*.arb` on `flutter pub get` / `flutter run`.

## Test

```
flutter test
```
