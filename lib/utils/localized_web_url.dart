import 'package:flutter/widgets.dart';

import '../config/config.dart';

String buildLocalizedWebUrl(
    BuildContext context,
    String path,
    ) {
  final String languageCode =
      Localizations.localeOf(context).languageCode;

  final String normalizedBaseUrl = AppConfig.baseUrl.endsWith('/')
      ? AppConfig.baseUrl.substring(
    0,
    AppConfig.baseUrl.length - 1,
  )
      : AppConfig.baseUrl;

  final String normalizedPath =
  path.startsWith('/') ? path : '/$path';

  final Uri uri = Uri.parse(
    '$normalizedBaseUrl$normalizedPath',
  );

  return uri
      .replace(
    queryParameters: <String, String>{
      ...uri.queryParameters,
      'lang': languageCode,
    },
  )
      .toString();
}