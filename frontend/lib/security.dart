import 'dart:convert';

import 'package:prbd_2526_a03/api_client.dart';

class Security {
  // static Future<bool> checkEmail({String? email}) async {
  //   final response = await ApiClient.post(
  //     'does_email_exists',
  //     body: json.encode({'email': email}),
  //     anonymous: true,
  //   );
  //
  //   final dynamic body = json.decode(response.body);
  //   if (response.statusCode != 200){
  //     throw Exception('No account linked to this email');
  //   }
  //   return body;
  // }

  static Future<String?> login(String email, String password) async {
    final response = await ApiClient.post(
      'login',
      body: json.encode({'email' : email, 'password': password}),
      anonymous: true,
    );

    if (response.statusCode != 200){
      throw Exception('Failed to login');
    }
    final dynamic body = json.decode(response.body);
    String token = body['token'];
    return token;
  }
}