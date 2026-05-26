import 'dart:convert';

import 'package:prbd_2526_a03/core/services/api_client.dart';
import 'package:prbd_2526_a03/models/reservation.dart';

class ReservationServices {

  static Future<List<Reservation>> getMyReservations() async {
    final response = await ApiClient.post(
      'get_my_reservations'
    );

    if(response.statusCode != 200){
      throw Exception('Failed to get reservations');
    }

    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;
    return rows.map((row) => Reservation.fromJson(row)).toList();
  }
}