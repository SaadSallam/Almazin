import '../../../core/navigation/app_paths.dart';

class EmployeeAccessGuard {
  EmployeeAccessGuard._();

  static bool _isUnlocked = false;
  static String _lastPath = '';

  static bool get isUnlocked => _isUnlocked;
  static void unlock() => _isUnlocked = true;
  static void lock() => _isUnlocked = false;

  static String? redirect(String path) {
    if (path == AppPaths.pinLock) return null;

    if (_isUnlocked && _lastPath.startsWith(AppPaths.employees) && !path.startsWith(AppPaths.employees)) {
      _isUnlocked = false;
    }

    if (path.startsWith(AppPaths.employees)) {
      if (!_isUnlocked) return AppPaths.pinLock;
      _lastPath = path;
      return null;
    }

    _lastPath = path;
    return null;
  }
}
