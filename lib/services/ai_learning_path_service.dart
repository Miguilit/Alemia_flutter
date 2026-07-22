import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/ai_learning_path.dart';
import '../models/ai_learning_path_readiness.dart';
import '../models/ai_learning_profile.dart';
import 'base_service.dart';

String _aiLearningPathServiceMessage(String key) {
  final String language = Intl.getCurrentLocale()
      .split(RegExp(r'[-_]'))
      .first
      .toLowerCase();

  const Map<String, Map<String, String>> messages =
      <String, Map<String, String>>{
        'request_failed': <String, String>{
          'fr': 'La demande n’a pas pu être finalisée.',
          'en': 'The request could not be completed.',
          'nl': 'De aanvraag kon niet worden voltooid.',
          'de': 'Die Anfrage konnte nicht abgeschlossen werden.',
        },
        'invalid_response': <String, String>{
          'fr': 'Le serveur a renvoyé une réponse invalide.',
          'en': 'The server returned an invalid response.',
          'nl': 'De server heeft een ongeldig antwoord teruggestuurd.',
          'de': 'Der Server hat eine ungültige Antwort zurückgegeben.',
        },
        'invalid_data': <String, String>{
          'fr': 'La réponse ne contient pas de données valides.',
          'en': 'The response does not contain valid data.',
          'nl': 'Het antwoord bevat geen geldige gegevens.',
          'de': 'Die Antwort enthält keine gültigen Daten.',
        },
      };

  final Map<String, String> values =
      messages[key] ?? messages['request_failed']!;

  return values[language] ?? values['en']!;
}

class AiLearningPathService extends BaseService {
  static const Duration _defaultTimeout = Duration(seconds: 60);

  static const Duration _generationTimeout = Duration(minutes: 3);

  Future<AiLearningProfile> fetchProfile() async {
    final Uri url = Uri.parse(
      '${BaseService.baseUrl}/ai-learning-paths/profile',
    );

    final http.Response response = await http
        .get(url, headers: await getHeaders())
        .timeout(_defaultTimeout);

    final Map<String, dynamic> body = _decodeSuccessfulResponse(response);

    return AiLearningProfile.fromJson(_requiredDataMap(body));
  }

  Future<AiLearningProfile> updateProfile(AiLearningProfile profile) async {
    final Uri url = Uri.parse(
      '${BaseService.baseUrl}/ai-learning-paths/profile',
    );

    final http.Response response = await http
        .put(
          url,
          headers: await getHeaders(),
          body: jsonEncode(profile.toUpdateJson()),
        )
        .timeout(_defaultTimeout);

    final Map<String, dynamic> body = _decodeSuccessfulResponse(response);

    return AiLearningProfile.fromJson(_requiredDataMap(body));
  }

  Future<AiLearningPathReadiness> fetchReadiness() async {
    final Uri url = Uri.parse(
      '${BaseService.baseUrl}/ai-learning-paths/readiness',
    );

    final http.Response response = await http
        .get(url, headers: await getHeaders())
        .timeout(_defaultTimeout);

    final Map<String, dynamic> body = _decodeSuccessfulResponse(response);

    return AiLearningPathReadiness.fromJson(_requiredDataMap(body));
  }

  Future<AiLearningPath?> fetchCurrentPath() async {
    final Uri url = Uri.parse(
      '${BaseService.baseUrl}/ai-learning-paths/current',
    );

    final http.Response response = await http
        .get(url, headers: await getHeaders())
        .timeout(_defaultTimeout);

    final Map<String, dynamic> body = _decodeSuccessfulResponse(response);

    final dynamic data = body['data'];

    if (data == null) {
      return null;
    }

    return AiLearningPath.fromJson(_asMap(data));
  }

  Future<AiLearningPath> fetchPath(int pathId) async {
    final Uri url = Uri.parse(
      '${BaseService.baseUrl}/ai-learning-paths/$pathId',
    );

    final http.Response response = await http
        .get(url, headers: await getHeaders())
        .timeout(_defaultTimeout);

    final Map<String, dynamic> body = _decodeSuccessfulResponse(response);

    return AiLearningPath.fromJson(_requiredDataMap(body));
  }

  Future<AiLearningPath> generatePath({required String locale}) async {
    final Uri url = Uri.parse(
      '${BaseService.baseUrl}/ai-learning-paths/generate',
    );

    final http.Response response = await http
        .post(
          url,
          headers: await getHeaders(),
          body: jsonEncode(<String, dynamic>{'locale': locale}),
        )
        .timeout(_generationTimeout);

    final Map<String, dynamic> body = _decodeSuccessfulResponse(response);

    return AiLearningPath.fromJson(_requiredDataMap(body));
  }

  Future<void> archivePath(int pathId) async {
    final Uri url = Uri.parse(
      '${BaseService.baseUrl}/ai-learning-paths/$pathId',
    );

    final http.Response response = await http
        .delete(url, headers: await getHeaders())
        .timeout(_defaultTimeout);

    _decodeSuccessfulResponse(response);
  }

  Map<String, dynamic> _decodeSuccessfulResponse(http.Response response) {
    final Map<String, dynamic> body = _decodeBody(response.body);

    final bool successful =
        response.statusCode >= 200 && response.statusCode < 300;

    if (!successful) {
      throw AiLearningPathApiException(
        statusCode: response.statusCode,
        code: body['code']?.toString(),
        message:
            body['message']?.toString() ??
            _aiLearningPathServiceMessage('request_failed'),
        data: body['data'],
      );
    }

    return body;
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final dynamic decoded = jsonDecode(body);

      return _asMap(decoded);
    } on FormatException {
      throw AiLearningPathApiException(
        statusCode: 0,
        message: _aiLearningPathServiceMessage('invalid_response'),
      );
    }
  }

  Map<String, dynamic> _requiredDataMap(Map<String, dynamic> body) {
    final dynamic data = body['data'];

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw AiLearningPathApiException(
      statusCode: 0,
      message: _aiLearningPathServiceMessage('invalid_data'),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }
}

class AiLearningPathApiException implements Exception {
  const AiLearningPathApiException({
    required this.statusCode,
    required this.message,
    this.code,
    this.data,
  });

  final int statusCode;
  final String? code;
  final String message;
  final dynamic data;

  Map<String, dynamic>? get dataMap {
    if (data is Map<String, dynamic>) {
      return data as Map<String, dynamic>;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data as Map);
    }

    return null;
  }

  @override
  String toString() => message;
}
