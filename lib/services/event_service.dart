import 'dart:convert';

import 'package:http/http.dart' as http;

import 'base_service.dart';

class EventService extends BaseService {
  Future<http.Response> fetchEvents({
    String filter = 'upcoming',
    String priceFilter = 'all',
    String search = '',
    int page = 1,
  }) async {
    final Map<String, String> queryParameters = <String, String>{
      'filter': filter,
      'page': '$page',
    };

    if (priceFilter != 'all') {
      queryParameters['price'] = priceFilter;
    }

    final String normalizedSearch = search.trim();
    if (normalizedSearch.isNotEmpty) {
      queryParameters['search'] = normalizedSearch;
    }

    final Uri url = Uri.parse(
      '${BaseService.baseUrl}/events',
    ).replace(queryParameters: queryParameters);

    return http.get(url, headers: await getHeaders());
  }

  Future<http.Response> fetchEventDetails(int id) async {
    final Uri url = Uri.parse('${BaseService.baseUrl}/events/$id');
    return http.get(url, headers: await getHeaders());
  }

  Future<http.Response> bookEvent({
    required int eventId,
    required Map<String, dynamic> data,
  }) async {
    final Uri url = Uri.parse('${BaseService.baseUrl}/events/$eventId/book');
    return http.post(url, headers: await getHeaders(), body: jsonEncode(data));
  }

  Future<http.Response> getMyBookings({int page = 1}) async {
    final Uri url = Uri.parse(
      '${BaseService.baseUrl}/user/bookings?page=$page',
    );
    return http.get(url, headers: await getHeaders());
  }

  Future<http.Response> getBookingDetails(int id) async {
    final Uri url = Uri.parse('${BaseService.baseUrl}/user/bookings/$id');
    return http.get(url, headers: await getHeaders());
  }
}
