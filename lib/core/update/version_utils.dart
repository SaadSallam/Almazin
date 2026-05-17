/// Semantic version comparison utility.
/// Handles vX.X.X and X.X.X formats from GitHub Releases.
abstract final class VersionUtils {
  /// Check if version string is valid semantic version.
  /// Accepts: v1.0.0, 1.0.0, v1.2.3-beta
  static bool isValid(String version) {
    final cleaned = version.startsWith('v') ? version.substring(1) : version;
    final parts = cleaned.split('.');
    if (parts.length < 3) return false;

    final major = int.tryParse(parts[0]);
    if (major == null || major < 0) return false;

    final minor = int.tryParse(parts[1]);
    if (minor == null || minor < 0) return false;

    // Patch can have prerelease suffix like 1.0.0-beta
    final patchPart = parts[2].split('-').first;
    final patch = int.tryParse(patchPart);
    if (patch == null || patch < 0) return false;

    return true;
  }

  /// Parse version string to [major, minor, patch].
  /// Handles: "v1.0.0", "1.0.0", "nightly-20260516"
  static (int major, int minor, int patch)? parse(String version) {
    final cleaned = version.startsWith('v') ? version.substring(1) : version;
    final parts = cleaned.split('.');
    if (parts.length < 3) return null;

    final major = int.tryParse(parts[0]);
    final minor = int.tryParse(parts[1]);
    final patchStr = parts[2].split('-').first; // Remove pre-release suffix
    final patch = int.tryParse(patchStr);

    if (major == null || minor == null || patch == null) return null;
    return (major, minor, patch);
  }

  /// Compare two version strings.
  /// Returns: 1 if a > b, -1 if a < b, 0 if equal.
  static int compare(String a, String b) {
    final va = parse(a);
    final vb = parse(b);
    if (va == null || vb == null) return 0;

    if (va.$1 != vb.$1) return va.$1 > vb.$1 ? 1 : -1;
    if (va.$2 != vb.$2) return va.$2 > vb.$2 ? 1 : -1;
    if (va.$3 != vb.$3) return va.$3 > vb.$3 ? 1 : -1;
    return 0;
  }

  /// Check if [newer] is greater than [current].
  static bool isNewer(String current, String newer) {
    return compare(current, newer) < 0;
  }

  /// Format version for display (strips 'v' prefix).
  static String display(String version) {
    return version.startsWith('v') ? version.substring(1) : version;
  }
}
