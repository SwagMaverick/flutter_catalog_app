import 'package:flutter_catalog_app/core/errors/failures.dart';
import 'package:flutter_catalog_app/l10n/app_localizations.dart';

extension FailureLocalization on Failure {
  String localizedMessage(AppLocalizations l10n) => switch (this) {
        ServerFailure() => l10n.errorServer,
        NetworkFailure() => l10n.errorNetwork,
        TimeoutFailure() => l10n.errorTimeout,
        CacheFailure() => l10n.errorCache,
        CancelledFailure() || UnknownFailure() => l10n.errorUnknown,
      };
}
