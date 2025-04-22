import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snacknload/snacknload.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'package:path/path.dart' as path;

class AuthService with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  User? _user;
  String? _token;
  String? _error;
  bool _isLoading = false;

  AuthService(this._token);

  User? get user => _user;

  String? get token => _token;

  String? get error => _error;

  bool get isLoading => _isLoading;

  bool get isAuthenticated => _token != null;

  Future<void> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      SnackNLoad.show();
      final response = await ApiService.instance.requestToken(
        username: username,
        password: password,
      );
      SnackNLoad.dismiss();

      if (response.data != null && response.data['access_token'] != null) {
        _token = response.data['access_token'];
        ApiService.instance.setAuthToken(_token ?? "");
        await _storage.write(key: 'token', value: _token);
        await fetchUser();
        if (_user != null) {
          Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
        }
      } else {
        SnackNLoad.showSnackBar(response.message ?? "Something went wrong");
      }
    } catch (e) {
      _error = 'Invalid username or password';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String email,
    String password,
    String name,
    DateTime dob,
    double height,
    double weight, {
    required String profileImageFileName,
    required List<int> profileImageByte,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var res = await ApiService.instance.post('/api/auth/register', {
        'email': email,
        'password': password,
        'name': name,
        'dob': dob.toIso8601String(),
        'height': height,
        'weight': weight,
      });
      log(res.message ?? "");
      SnackNLoad.showSnackBar(
        res.message ?? "Something went wrong!",
        type: Type.info,
        position: Position.top,
        duration: Duration(seconds: 3),
      );
      if (res.success) {
        _uploadProfileImage(
          fileByte: profileImageByte,
          fileName: profileImageFileName,
          id: (res.data['id'] ?? name),
        );
      }
      return res.success;
    } catch (e) {
      log(e.toString());
      _error = 'Registration failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUser() async {
    try {
      final response = await ApiService.instance.get('/api/auth/me');
      if (response.data != null) {
        _user = User.fromJson(response.data);
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch user data';
    }
  }

  Future<void> autoLogin() async {
    _token = await _storage.read(key: 'token');
    if (_token != null) {
      await fetchUser();
    }
    if (_token != null) {
      ApiService.instance.setAuthToken(_token!);
    }
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await _storage.delete(key: 'token');
    _token = null;
    _user = null;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    // Navigator.pushNamedAndRemoveUntil(context, '/login',(_) => false,);
  }

  Future<void> _uploadProfileImage({
    required List<int> fileByte,
    required String id,
    required String fileName,
  }) async {
    try {
      var uploadRes = await ApiService.instance.uploadFile(
        fileName: fileName,
        fileByte: fileByte,
        otherParams: {"unique_id": id},
      );
      log("upload file res - ${uploadRes.message}");
    } catch (e) {
      log(e.toString());
    }
  }

  Future<bool> deleteAccount({required String reason}) async {
    var res = await ApiService.instance.delete(
      "/api/auth/users/${user?.id}/delete?reason=${Uri.encodeComponent(reason)}",
    );
    return res.success;
  }
}
