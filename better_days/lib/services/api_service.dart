import 'dart:developer';
import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'package:better_days/core/navigator_service.dart';
import 'package:better_days/services/auth_service.dart';
import 'package:better_days/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/api_response.dart';

String? token;

class ApiService {
  static ApiService get instance => ApiService();

  String baseUrl = AppConstants.apiBaseUrl;

  Future<ApiResponse> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  Future<ApiResponse> uploadFile({
    required List<int> fileByte,
    required String fileName,
    required Map<String, String> otherParams,
  }) async {
    var multipartReq = http.MultipartRequest(
      "post",
      Uri.parse("$baseUrl/api/upload"),
    );
    multipartReq.files.add(http.MultipartFile.fromBytes("file", fileByte));
    multipartReq.fields.addAll(otherParams);
    multipartReq.headers.addAll({
      'Authorization': 'Bearer $token',
      'Content-Type': 'multipart/form-data',
    });

    final responseStream = await multipartReq.send();
    var responseBody = await responseStream.stream.bytesToString();

    return _handleResponse(
      http.Response(responseBody, responseStream.statusCode),
    );
  }

  Future<ApiResponse> post(String endpoint, dynamic data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    return _handleResponse(response);
  }

  Future<ApiResponse> patch(String endpoint, dynamic data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    return _handleResponse(response);
  }

  Future<ApiResponse> requestToken({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/token_auth');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'username': username,
          'password': password,
          'scope': '',
          'client_id': '',
          'client_secret': '',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      log(e.toString());
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> delete(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    return _handleResponse(response);
  }

  ApiResponse _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      if (navigatorKey.currentState?.context != null) {
        navigatorKey.currentState?.context.read<AuthService>().logout(
          navigatorKey.currentState!.context,
        );
      }
    }

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(json.decode(response.body), (data) => data);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  void setAuthToken(String tokenV) {
    token = tokenV;
  }
}
