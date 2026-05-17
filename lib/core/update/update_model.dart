import 'package:equatable/equatable.dart';

/// Represents a GitHub Release for update checking.
class ReleaseInfo extends Equatable {
  const ReleaseInfo({
    required this.tagName,
    required this.name,
    required this.publishedAt,
    required this.body,
    required this.isPrerelease,
    required this.isDraft,
    required this.htmlUrl,
    required this.assets,
  });

  final String tagName; // e.g., "v1.0.0"
  final String name; // e.g., "Almazin App v1.0.0"
  final DateTime publishedAt;
  final String body; // Release notes
  final bool isPrerelease;
  final bool isDraft;
  final String htmlUrl;
  final List<ReleaseAsset> assets;

  /// Find the setup.exe installer asset.
  ReleaseAsset? get setupAsset => assets.where(
        (a) => a.name.startsWith('Almazin-Setup-') && a.name.endsWith('.exe'),
      ).firstOrNull;

  @override
  List<Object?> get props => [tagName, name, publishedAt, isPrerelease, isDraft];
}

/// Represents a release asset (downloadable file).
class ReleaseAsset extends Equatable {
  const ReleaseAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
  });

  final String name;
  final String downloadUrl;
  final int size;

  @override
  List<Object?> get props => [name, downloadUrl, size];
}

/// Update check result.
class UpdateCheckResult {
  const UpdateCheckResult({
    required this.hasUpdate,
    this.latestRelease,
    this.error,
    this.isFromCache = false,
  });

  final bool hasUpdate;
  final ReleaseInfo? latestRelease;
  final String? error;
  final bool isFromCache;
}

/// Update state for UI.
enum UpdateState { idle, checking, available, downloading, installing, error, upToDate }
