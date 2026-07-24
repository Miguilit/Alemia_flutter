import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthCancelledException implements Exception {
  const GoogleAuthCancelledException();
}

class GoogleAuthConfigurationException implements Exception {
  const GoogleAuthConfigurationException([this.message]);

  final String? message;
}

class GoogleAuthService {
  GoogleAuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuthOverride = firebaseAuth,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth? _firebaseAuthOverride;
  final GoogleSignIn _googleSignIn;

  FirebaseAuth get _firebaseAuth =>
      _firebaseAuthOverride ?? FirebaseAuth.instance;

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (Firebase.apps.isEmpty) {
      throw const GoogleAuthConfigurationException(
        'Firebase is not initialized.',
      );
    }

    if (_initialized) {
      return;
    }

    try {
      await _googleSignIn.initialize();
      _initialized = true;
    } on GoogleSignInException catch (error) {
      throw GoogleAuthConfigurationException(error.description);
    }
  }

  Future<String> signInAndGetFirebaseIdToken() async {
    await _ensureInitialized();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw const GoogleAuthConfigurationException(
        'Google Sign-In is unavailable on this platform.',
      );
    }

    GoogleSignInAccount googleUser;

    try {
      googleUser = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const GoogleAuthCancelledException();
      }

      if (error.code == GoogleSignInExceptionCode.clientConfigurationError ||
          error.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw GoogleAuthConfigurationException(error.description);
      }

      rethrow;
    }

    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final String? googleIdToken = googleAuth.idToken;

    if (googleIdToken == null || googleIdToken.isEmpty) {
      throw const GoogleAuthConfigurationException(
        'Google did not return an ID token.',
      );
    }

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleIdToken,
    );

    final UserCredential userCredential = await _firebaseAuth
        .signInWithCredential(credential);

    final String? firebaseIdToken = await userCredential.user?.getIdToken(true);

    if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
      throw const GoogleAuthConfigurationException(
        'Firebase did not return an ID token.',
      );
    }

    return firebaseIdToken;
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {
      // The Laravel session still needs to be cleared even if Firebase fails.
    }

    try {
      if (_initialized) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // Ignore provider sign-out failures during local session cleanup.
    }
  }
}
