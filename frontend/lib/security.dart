import 'dart:convert';

import 'package:prbd_2526_a03/api_client.dart';

class Security {
  static Future<bool> checkEmail({String? email}) async {
    final response = await ApiClient.post(
      'does_email_exists',
      body: json.encode({'email': email}),
      anonymous: true,
    );

    final dynamic body = json.decode(response.body);
    if (response.statusCode != 200){
      throw Exception('No account linked to this email');
    }
    return body;
  }
}