import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;

import 'update_model.dart';
import 'version_utils.dart';

/// Production-grade resilient auto-update service.
/// All operations are fail-safe and never crash the app.
class UpdateService {
  UpdateService({
    required this.currentVersion,
    this.owner = 'SaadSallam',
    this.repo = 'Almazin',
    this.maxRetries = 3,
    this.timeoutSeconds = 15,
  }) : _cacheBox = Hive.box<dynamic>('update_cache');

  final String currentVersion;
  final String owner;
  final String repo;
  final int maxRetries;
  final int timeoutSeconds;

  static const String _apiBase = 'https://api.github.com';
  static const String _installerPrefix = 'Almazin-Setup-';
  static const String _cacheVersionKey = 'cached_version';
  static const String _cacheReleaseKey = 'cached_release_json';
  static const String _cacheTimestampKey = 'cached_timestamp';

  final Box<dynamic> _cacheBox;

  /// Unified update check with all resilience features.
  Future<UpdateCheckResult> checkForUpdate() async {
    _log('[UPDATE] check started for v$currentVersion');

    // Step 1: Try to get latest release from GitHub
    final result = await _fetchWithResilience();

    // Step 2: If GitHub fails, try cached fallback
    if (result.error != null && _hasCachedRelease()) {
      _log('[UPDATE] GitHub failed, using cached fallback');
      return _getCachedFallback();
    }

    // Step 3: If both fail, return graceful offline message
    if (result.error != null) {
      _log('[UPDATE] failure: ${result.error}');
      return UpdateCheckResult(
        hasUpdate: false,
        error: 'Update check skipped (offline mode)',
      );
    }

    // Step 4: Validate and cache the release
    final validated = _validateRelease(result.release);
    if (validated == null) {
      _log('[UPDATE] no valid release found, using fallback if available');
      return _hasCachedRelease()
          ? _getCachedFallback()
          : const UpdateCheckResult(hasUpdate: false);
    }

    // Step 5: Cache successful release
    await _cacheRelease(validated);

    // Step 6: Compare versions
    final hasUpdate = VersionUtils.isNewer(currentVersion, validated.tagName);
    _log('[UPDATE] release v${validated.tagName} found, hasUpdate=$hasUpdate');

    return UpdateCheckResult(
      hasUpdate: hasUpdate,
      latestRelease: hasUpdate ? validated : null,
      isFromCache: false,
    );
  }

  /// Fetch with retry, timeout, and exponential backoff.
  Future<_FetchResult> _fetchWithResilience() async {
    Duration baseDelay = const Duration(seconds: 1);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      _log('[UPDATE] attempt $attempt/$maxRetries');

      try {
        final response = await _makeRequest();

        // Handle rate limiting specifically
        if (response.statusCode == 403) {
          final remaining = response.headers['x-ratelimit-remaining'];
          final reset = response.headers['x-ratelimit-reset'];
          _log('[UPDATE] rate limit detected, remaining=$remaining, reset=$reset');
          return _FetchResult(
            error: 'Update temporarily unavailable',
            isRateLimited: true,
          );
        }

        // Handle 5xx server errors with retry
        if (response.statusCode >= 500 && response.statusCode < 600) {
          _log('[UPDATE] server error ${response.statusCode}, will retry...');
          if (attempt < maxRetries) {
            await Future.delayed(baseDelay);
            baseDelay *= 2; // Exponential backoff
            continue;
          }
          return _FetchResult(error: 'GitHub server unavailable');
        }

        // Handle 404 as "no releases"
        if (response.statusCode == 404) {
          _log('[UPDATE] 404 - no releases found');
          return _FetchResult(error: 'No updates available');
        }

        // Handle non-200 status codes
        if (response.statusCode != 200) {
          return _FetchResult(
            error: 'Failed to check (${response.statusCode})',
          );
        }

        // Success - parse and return
        final releases = jsonDecode(response.body) as List<dynamic>;
        final parsed = _parseReleases(releases);
        return _FetchResult(release: parsed);
      } on SocketException catch (e) {
        _log('[UPDATE] socket error: ${e.message}');
        if (attempt < maxRetries) {
          await Future.delayed(baseDelay);
          baseDelay *= 2;
          continue;
        }
        return _FetchResult(error: 'Network unavailable');
      } on TimeoutException {
        _log('[UPDATE] timeout on attempt $attempt');
        if (attempt < maxRetries) {
          await Future.delayed(baseDelay);
          baseDelay *= 2;
          continue;
        }
        return _FetchResult(error: 'Connection timed out');
      } catch (e) {
        _log('[UPDATE] unexpected error: $e');
        return _FetchResult(error: 'Update check failed');
      }
    }

    return _FetchResult(error: 'Max retries exceeded');
  }

  /// Make HTTP request with proper timeout and headers.
  Future<http.Response> _makeRequest() async {
    final url = Uri.parse('$_apiBase/repos/$owner/$repo/releases');
    return http
        .get(
          url,
          headers: {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
        )
        .timeout(Duration(seconds: timeoutSeconds));
  }

  /// Parse releases from JSON, extracting valid stable releases with installers.
  ReleaseInfo? _parseReleases(List<dynamic> releases) {
    if (releases.isEmpty) return null;

    for (final r in releases) {
      try {
        final release = r as Map<String, dynamic>;

        // Skip drafts and prereleases
        if (release['draft'] == true || release['prerelease'] == true) {
          continue;
        }

        final tagName = release['tag_name'] as String?;
        if (tagName == null || tagName.isEmpty) continue;

        // Validate semantic version
        if (!VersionUtils.isValid(tagName)) continue;

        final assets = (release['assets'] as List<dynamic>?);
        if (assets == null || assets.isEmpty) continue;

        // Find setup.exe asset
        ReleaseAsset? setupAsset;
        for (final a in assets) {
          final asset = a as Map<String, dynamic>;
          final name = asset['name'] as String? ?? '';
          if (name.startsWith(_installerPrefix) && name.endsWith('.exe')) {
            setupAsset = ReleaseAsset(
              name: name,
              downloadUrl: asset['browser_download_url'] as String? ?? '',
              size: asset['size'] as int? ?? 0,
            );
            break;
          }
        }
        if (setupAsset == null) continue;

        // Valid release found
        return ReleaseInfo(
          tagName: tagName,
          name: release['name'] as String? ?? tagName,
          publishedAt: DateTime.tryParse(release['published_at'] as String? ?? '') ?? DateTime.now(),
          body: release['body'] as String? ?? '',
          isPrerelease: release['prerelease'] as bool? ?? false,
          isDraft: release['draft'] as bool? ?? false,
          htmlUrl: release['html_url'] as String? ?? '',
          assets: [setupAsset],
        );
      } catch (e) {
        // Skip malformed releases silently
        continue;
      }
    }

    return null;
  }

  /// Validate that a release is safe to use.
  ReleaseInfo? _validateRelease(ReleaseInfo? release) {
    if (release == null) return null;

    // Double-check version validity
    if (!VersionUtils.isValid(release.tagName)) return null;

    // Ensure we have a valid setup asset
    final setup = release.setupAsset;
    if (setup == null) return null;
    if (setup.downloadUrl.isEmpty) return null;

    return release;
  }

  /// Check if we have a cached release.
  bool _hasCachedRelease() {
    return _cacheBox.get(_cacheVersionKey) != null;
  }

  /// Get cached fallback release.
  UpdateCheckResult _getCachedFallback() {
    try {
      final json = _cacheBox.get(_cacheReleaseKey) as String?;
      final version = _cacheBox.get(_cacheVersionKey) as String?;
      final timestamp = _cacheBox.get(_cacheTimestampKey) as int?;

      if (json == null || version == null) {
        return const UpdateCheckResult(hasUpdate: false);
      }

      _log('[UPDATE] using cached release v$version (cached at ${DateTime.fromMillisecondsSinceEpoch(timestamp ?? 0)})');

      final decoded = jsonDecode(json) as Map<String, dynamic>;
      final release = ReleaseInfo(
        tagName: decoded['tagName'] as String,
        name: decoded['name'] as String,
        publishedAt: DateTime.parse(decoded['publishedAt'] as String),
        body: decoded['body'] as String,
        isPrerelease: decoded['isPrerelease'] as bool,
        isDraft: decoded['isDraft'] as bool,
        htmlUrl: decoded['htmlUrl'] as String,
        assets: [
          ReleaseAsset(
            name: decoded['assetName'] as String,
            downloadUrl: decoded['assetUrl'] as String,
            size: decoded['assetSize'] as int,
          ),
        ],
      );

      final hasUpdate = VersionUtils.isNewer(currentVersion, release.tagName);
      return UpdateCheckResult(
        hasUpdate: hasUpdate,
        latestRelease: hasUpdate ? release : null,
        isFromCache: true,
      );
    } catch (e) {
      _log('[UPDATE] failed to parse cached release: $e');
      return const UpdateCheckResult(hasUpdate: false);
    }
  }

  /// Cache a successful release.
  Future<void> _cacheRelease(ReleaseInfo release) async {
    try {
      final setup = release.setupAsset;
      if (setup == null) return;

      final cacheJson = jsonEncode({
        'tagName': release.tagName,
        'name': release.name,
        'publishedAt': release.publishedAt.toIso8601String(),
        'body': release.body,
        'isPrerelease': release.isPrerelease,
        'isDraft': release.isDraft,
        'htmlUrl': release.htmlUrl,
        'assetName': setup.name,
        'assetUrl': setup.downloadUrl,
        'assetSize': setup.size,
      });

      await _cacheBox.put(_cacheVersionKey, release.tagName);
      await _cacheBox.put(_cacheReleaseKey, cacheJson);
      await _cacheBox.put(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);

      _log('[UPDATE] cached release v${release.tagName}');
    } catch (e) {
      _log('[UPDATE] failed to cache: $e');
    }
  }

  /// Download the setup.exe installer to a temporary location.
  Future<String> downloadInstaller(
    ReleaseAsset asset, {
    void Function(double progress)? onProgress,
  }) async {
    _log('[UPDATE] downloading ${asset.name}');

    try {
      final tempDir = Directory.systemTemp;
      final destPath = path.join(tempDir.path, asset.name);

      final request = http.Request('GET', Uri.parse(asset.downloadUrl));
      final response = await http.Client().send(request).timeout(
            const Duration(minutes: 5),
          );

      if (response.statusCode != 200) {
        throw Exception('Download failed: ${response.statusCode}');
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      final file = File(destPath);
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        receivedBytes += chunk.length;
        sink.add(chunk);

        if (totalBytes > 0 && onProgress != null) {
          onProgress(receivedBytes / totalBytes);
        }
      }

      await sink.close();
      _log('[UPDATE] downloaded to $destPath');
      return destPath;
    } catch (e) {
      _log('[UPDATE] download error: $e');
      rethrow;
    }
  }

  /// Launch the installer silently and close the app.
  Future<void> installAndRestart(String installerPath) async {
    _log('[UPDATE] installing and restarting');

    try {
      await Process.start(
        installerPath,
        const [
          '/VERYSILENT',
          '/SUPPRESSMSGBOXES',
          '/NORESTART',
          '/SP-',
        ],
        mode: ProcessStartMode.detached,
      );

      await Future.delayed(const Duration(seconds: 2));

      final exePath = Platform.resolvedExecutable;

      final batchPath = path.join(
        path.dirname(installerPath),
        'relaunch.bat',
      );

      final batchContent = '''
@echo off
timeout /t 5 /nobreak > nul
start "" "$exePath"
del /f /q "$installerPath"
del /f /q "%~f0"
''';

      await File(batchPath).writeAsString(batchContent);

      await Process.start(
        'cmd.exe',
        ['/c', 'start', '', '/min', batchPath],
        mode: ProcessStartMode.detached,
      );

      exit(0);
    } catch (e) {
      _log('[UPDATE] install error: $e');
      rethrow;
    }
  }

  /// Structured logging helper.
  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}

/// Internal result class for fetch operations.
class _FetchResult {
  const _FetchResult({
    this.release,
    this.error,
    this.isRateLimited = false,
  });

  final ReleaseInfo? release;
  final String? error;
  final bool isRateLimited;

  bool get hasError => error != null;
}