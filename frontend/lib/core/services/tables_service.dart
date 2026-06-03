import 'dart:convert';

import '../../models/tables.dart';
import 'api_client.dart';

class TablesService {
  static Future<List<Tables>> getTablesForReservation(int reservationId) async {
    final response = await ApiClient.post(
        'get_tables_for_reservation',
        body: json.encode({'reservation_id': reservationId}),
        anonymous: false
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch restaurants, please try again later');
    }

    final dynamic body = json.decode(response.body);
    final List<dynamic> rows = body;
    return rows.map((rows) => Tables.fromJson(rows)).toList();
  }
}