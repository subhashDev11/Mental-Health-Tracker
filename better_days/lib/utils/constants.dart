import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  static const String appName = 'Better days Tracker';
  static String apiBaseUrl = getBaseUrl;

  static String  get getBaseUrl {
    const port = '8000'; // Change this to your API port

    if (kIsWeb) {
      // return 'http://localhost:$port';
      // return 'http://10.10.109.51:$port';
      return 'http://127.0.0.1:$port';
    } else if (Platform.isAndroid) {
      return 'http://192.168.35.243:$port';
    } else if (Platform.isIOS) {
      return 'http://localhost:$port';
    } else {
      return 'http://10.10.109.51:$port';
    }
  }
}

