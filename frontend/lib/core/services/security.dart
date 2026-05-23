import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:prbd_2526_a03/core/services/api_client.dart';

class Security {

  static Future<String?> login(String email, String password) async {
    try {
      final response = await ApiClient.post(
        'login',
        body: json.encode({'email': email, 'password': password}),
        anonymous: true,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to login');
      }
      final dynamic body = json.decode(response.body);
      String token = body['token'];
      return token;
    }catch (e, st) {
      debugPrint('$e\n$st');
      throw Exception('Failed to get user');
  }
  }

  static Future<String?> resetDataBase() async {
    final response = await ApiClient.post(
      'reset_database',
      anonymous: true,
    );

    if(response.statusCode != 204){
      throw Exception('Failed to reset data base');
    }

    return null;
  }

  static Future<bool> checkEmail({String? email}) async {
    final response = await ApiClient.post(
      'check_email_available',
      body: json.encode({'email': email}),
      anonymous: true,
    );
    if (response.statusCode != 200){
      throw Exception('Could not check the email');
    }

    final dynamic body = json.decode(response.body);

    return body;
  }

  static Future<bool> checkFullName({String? fullName}) async {
    final response = await ApiClient.post(
      'check_full_name_available',
      body: json.encode({'full_name': fullName}),
      anonymous: true,
    );

    if (response.statusCode != 200){
      throw Exception('Could not check the full name');
    }

    final dynamic body = json.decode(response.body);

    return body;
  }
}