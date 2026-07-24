import 'dart:convert';

import 'package:http/http.dart' as http;

import 'base_service.dart';

class AuthService extends BaseService {
  Future<http.Response> login(String email, String password) async {
    final Uri url = Uri.parse('${BaseService.baseUrl}/auth/login');
    return http.post(
      url,
      headers: await getHeaders(),
      body: jsonEncode(<String, String>{'email': email, 'password': password}),
    );
  }

  Future<http.Response> loginWithFirebase(String idToken) async {
    final Uri url = Uri.parse('${BaseService.baseUrl}/auth/firebase');
    return http.post(
      url,
      headers: await getHeaders(),
      body: jsonEncode(<String, String>{'id_token': idToken}),
    );
  }

  Future<http.Response> verifyOtp(String email, String code) async {
    final Uri url = Uri.parse('${BaseService.baseUrl}/auth/login/otp/verify');
    return http.post(
      url,
      headers: await getHeaders(),
      body: jsonEncode(<String, String>{'email': email, 'code': code}),
    );
  }

  Future<http.Response> resendOtp(String email) async {
    final Uri url = Uri.parse('${BaseService.baseUrl}/auth/login/otp/resend');
    return http.post(
      url,
      headers: await getHeaders(),
      body: jsonEncode(<String, String>{'email': email}),
    );
  }

  Future<http.Response> register(Map<String, dynamic> data) async {
    final Uri url = Uri.parse('${BaseService.baseUrl}/auth/register');
    return http.post(url, headers: await getHeaders(), body: jsonEncode(data));
  }

  Future<http.Response> logout() async {
    final Uri url = Uri.parse('${BaseService.baseUrl}/logout');
    return http.post(url, headers: await getHeaders());
  }

  Future<http.Response> getUser() async {
    final Uri url = Uri.parse('${BaseService.baseUrl}/user');
    return http.get(url, headers: await getHeaders());
  }
}
