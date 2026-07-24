import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/profile_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  User? _user;
  bool _isLoading = false;
  Map<String, dynamic>? _deletionRequestStatus;

  User? get user => _user;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get deletionRequestStatus => _deletionRequestStatus;
  bool get isAuthenticated => _user != null;

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // The caller will receive a stable generic error below.
    }

    return <String, dynamic>{
      'message': 'The server returned an invalid response.',
      'code': 'invalid_server_response',
    };
  }

  String? _firstValidationError(dynamic errors) {
    if (errors is! Map || errors.isEmpty) {
      return null;
    }

    for (final dynamic value in errors.values) {
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }

      if (value != null) {
        return value.toString();
      }
    }

    return null;
  }

  Future<void> loadUser() async {
    final String? token = await _authService.getToken();
    if (token == null) {
      return;
    }

    try {
      final http.Response response = await _authService.getUser();
      if (response.statusCode == 200) {
        _user = User.fromJson(_decodeResponse(response));
        await checkDeletionRequestStatus();
      } else {
        await _authService.clearToken();
      }
    } catch (error) {
      debugPrint('Error loading user: $error');
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final http.Response response = await _authService.login(email, password);
      final Map<String, dynamic> data = _decodeResponse(response);

      if (response.statusCode == 200) {
        if (data['otp_required'] == true) {
          return <String, dynamic>{
            'success': true,
            'otp_required': true,
            'message': data['message'],
            'code': data['code'],
            'email': data['email'] ?? email,
          };
        }

        final dynamic token = data['token'];
        final dynamic userJson = data['user'];

        if (token is! String || token.isEmpty || userJson is! Map) {
          return <String, dynamic>{
            'success': false,
            'code': 'invalid_server_response',
            'message': data['message'],
          };
        }

        _user = User.fromJson(Map<String, dynamic>.from(userJson));
        await _authService.saveToken(token);

        return <String, dynamic>{
          'success': true,
          'otp_required': false,
          'message': data['message'],
          'code': data['code'],
        };
      }

      return <String, dynamic>{
        'success': false,
        'message':
            _firstValidationError(data['errors']) ??
            data['message'] ??
            'Login failed',
        'code': data['code'],
        'errors': data['errors'],
      };
    } catch (error) {
      return <String, dynamic>{
        'success': false,
        'code': 'network_error',
        'message': error.toString(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String firebaseIdToken = await _googleAuthService
          .signInAndGetFirebaseIdToken();

      final http.Response response = await _authService.loginWithFirebase(
        firebaseIdToken,
      );
      final Map<String, dynamic> data = _decodeResponse(response);

      if (response.statusCode == 200) {
        final dynamic token = data['token'];
        final dynamic userJson = data['user'];

        if (token is! String || token.isEmpty || userJson is! Map) {
          await _googleAuthService.signOut();

          return <String, dynamic>{
            'success': false,
            'code': 'invalid_server_response',
            'message': data['message'],
          };
        }

        _user = User.fromJson(Map<String, dynamic>.from(userJson));
        await _authService.saveToken(token);

        return <String, dynamic>{
          'success': true,
          'message': data['message'],
          'code': data['code'],
        };
      }

      await _googleAuthService.signOut();

      return <String, dynamic>{
        'success': false,
        'message':
            _firstValidationError(data['errors']) ??
            data['message'] ??
            'Google login failed',
        'code': data['code'],
        'errors': data['errors'],
      };
    } on GoogleAuthCancelledException {
      return <String, dynamic>{
        'success': false,
        'cancelled': true,
        'code': 'google_login_cancelled',
      };
    } on GoogleAuthConfigurationException catch (error) {
      return <String, dynamic>{
        'success': false,
        'code': 'google_configuration_error',
        'message': error.message,
      };
    } on GoogleSignInException catch (error) {
      return <String, dynamic>{
        'success': false,
        'code': 'google_login_failed',
        'message': error.description,
      };
    } on FirebaseAuthException catch (error) {
      return <String, dynamic>{
        'success': false,
        'code': 'firebase_auth_failed',
        'message': error.message,
      };
    } catch (error) {
      return <String, dynamic>{
        'success': false,
        'code': 'network_error',
        'message': error.toString(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final http.Response response = await _authService.verifyOtp(email, code);
      final Map<String, dynamic> data = _decodeResponse(response);

      if (response.statusCode == 200) {
        final dynamic token = data['token'];
        final dynamic userJson = data['user'];

        if (token is! String || token.isEmpty || userJson is! Map) {
          return <String, dynamic>{
            'success': false,
            'code': 'invalid_server_response',
            'message': data['message'],
          };
        }

        _user = User.fromJson(Map<String, dynamic>.from(userJson));
        await _authService.saveToken(token);

        return <String, dynamic>{
          'success': true,
          'message': data['message'],
          'code': data['code'],
        };
      }

      return <String, dynamic>{
        'success': false,
        'message': data['message'] ?? 'Invalid OTP',
        'code': data['code'],
      };
    } catch (error) {
      return <String, dynamic>{
        'success': false,
        'code': 'network_error',
        'message': error.toString(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final http.Response response = await _authService.resendOtp(email);
      final Map<String, dynamic> data = _decodeResponse(response);

      if (response.statusCode == 200) {
        return <String, dynamic>{
          'success': true,
          'message': data['message'],
          'code': data['code'],
        };
      }

      return <String, dynamic>{
        'success': false,
        'message': data['message'] ?? 'Failed to resend OTP',
        'code': data['code'],
      };
    } catch (error) {
      return <String, dynamic>{
        'success': false,
        'code': 'network_error',
        'message': error.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final http.Response response = await _authService.register(userData);
      final Map<String, dynamic> data = _decodeResponse(response);

      if (response.statusCode == 201) {
        final bool verificationRequired =
            data['email_verification_required'] == true;
        final dynamic token = data['token'];
        final dynamic userJson = data['user'];

        if (verificationRequired) {
          return <String, dynamic>{
            'success': true,
            'email_verification_required': true,
            'message': data['message'],
            'code': data['code'],
          };
        }

        if (token is! String || token.isEmpty || userJson is! Map) {
          return <String, dynamic>{
            'success': false,
            'code': 'invalid_server_response',
            'message': data['message'],
          };
        }

        _user = User.fromJson(Map<String, dynamic>.from(userJson));
        await _authService.saveToken(token);

        return <String, dynamic>{
          'success': true,
          'email_verification_required': false,
          'message': data['message'],
          'code': data['code'],
        };
      }

      return <String, dynamic>{
        'success': false,
        'message':
            _firstValidationError(data['errors']) ??
            data['message'] ??
            'Registration failed',
        'code': data['code'],
        'errors': data['errors'],
      };
    } catch (error) {
      return <String, dynamic>{
        'success': false,
        'code': 'network_error',
        'message': error.toString(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkDeletionRequestStatus() async {
    try {
      _deletionRequestStatus = await ProfileService().getDeleteRequestStatus();
      notifyListeners();
    } catch (error) {
      debugPrint('Error checking deletion status: $error');
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {
      // Ignore network errors on logout.
    }

    await _googleAuthService.signOut();
    await _authService.clearToken();
    _user = null;
    notifyListeners();
  }
}
