import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:prbd_2526_a03/core/services/find_restaurant_service.dart';
import 'package:prbd_2526_a03/models/restaurant.dart';

class RestaurantProvider extends ChangeNotifier {
  final FindRestaurantService service;

  RestaurantProvider(this.service);

  List<Restaurant> restaurants = [];

  String filter = "";

  bool isLoading = false;

  Timer? _debounce;

  Future<void> onSearchChanged(String value) async {
    filter = value;

    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 400),
        () async {
        await _loadRestaurants();
        },
    );
  }

  Future<void> _loadRestaurants() async {
    isLoading = true;
    notifyListeners();

    restaurants =  await service.getMatchingRestaurants(filter.trim());

    isLoading = false;

    notifyListeners();

  }
}