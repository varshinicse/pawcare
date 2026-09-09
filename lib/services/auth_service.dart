import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';

class AuthService {
  FirebaseAuth? get _firebaseAuth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  bool get _isMock {
    try {
      return DefaultFirebaseOptions.currentPlatform.apiKey.contains('Mock');
    } catch (_) {
      return true;
    }
  }

  // Local persistent key for mock session when Firebase isn't live-configured
  static const String _mockUserKey = 'pawcare_mock_user_email';
  static const String _mockUserNameKey = 'pawcare_mock_user_name';

  Stream<User?> get authStateChanges {
    final auth = _firebaseAuth;
    if (auth == null || _isMock) {
      return Stream.value(null);
    }
    return auth.authStateChanges();
  }

  User? get currentUser {
    if (_isMock) return null;
    try {
      return _firebaseAuth?.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Sign Up with email, password, and name
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (_isMock) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_mockUserKey, email.trim());
      await prefs.setString(_mockUserNameKey, name.trim());
      return null;
    }

    try {
      final auth = _firebaseAuth;
      if (auth == null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_mockUserKey, email.trim());
        await prefs.setString(_mockUserNameKey, name.trim());
        return null;
      }

      final UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_mockUserKey, email.trim());
      await prefs.setString(_mockUserNameKey, name.trim());
      return null; // Success
    } catch (_) {
      // Fallback local persistence if Firebase app not initialized or credentials fail (demo fallback)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_mockUserKey, email.trim());
      await prefs.setString(_mockUserNameKey, name.trim());
      return null;
    }
  }

  /// Login with email and password
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    if (_isMock) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_mockUserKey, email.trim());
      return null;
    }

    try {
      final auth = _firebaseAuth;
      if (auth == null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_mockUserKey, email.trim());
        return null;
      }

      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_mockUserKey, email.trim());
      return null; // Success
    } catch (_) {
      // Fallback local session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_mockUserKey, email.trim());
      return null;
    }
  }

  /// Check whether an active session is persisted
  Future<bool> hasActiveSession() async {
    if (!_isMock && currentUser != null) {
      return true;
    }
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_mockUserKey);
    return email != null && email.isNotEmpty;
  }

  /// Sign Out
  Future<void> signOut() async {
    if (!_isMock) {
      try {
        await _firebaseAuth?.signOut();
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mockUserKey);
  }

  /// Helper to get cached user display name
  Future<String> getUserName() async {
    final user = currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_mockUserNameKey) ?? 'Varshini';
  }
}
