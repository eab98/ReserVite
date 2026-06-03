import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Tables {
  final int id;
  final int restaurant;
  final int tableNumber;
  final int capacity;

  const Tables({
    required this.id,
    required this.restaurant,
    required this.tableNumber,
    required this.capacity
});

  factory Tables.fromJson(Map<String, dynamic> json) {
    return Tables(
      id: json['id'],
      restaurant: json['restaurant'],
      tableNumber: json['table_number'],
      capacity: json['capacity']
    );
  }
}