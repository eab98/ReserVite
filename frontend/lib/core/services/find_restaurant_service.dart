import 'dart:convert';

import 'package:prbd_2526_a03/core/services/api_client.dart';
import 'package:prbd_2526_a03/models/restaurant.dart';
import 'package:prbd_2526_a03/models/services.dart';

class FindRestaurantService {

  static Future<List<Restaurant>> getMatchingRestaurants(String filter) async {
    final response = await ApiClient.post(
        'get_matching_restaurants',
        body: json.encode({'filter': filter}),
        anonymous: false
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch restaurants, please try again later');
    }

    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;
    return rows.map((rows) => Restaurant.fromJson(rows)).toList();
  }

  static Future<List<Services>> getServices(int restaurantId) async {
    final response = await ApiClient.post(
      'get_services',
      body: json.encode({'restaurant_id': restaurantId}),
      anonymous: false
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch services, please try again later');
    }

    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;
    return rows.map((rows) => Services.fromJson(rows)).toList();
  }
}