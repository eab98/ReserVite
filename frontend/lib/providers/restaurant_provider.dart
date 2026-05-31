import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/cupertino.dart';
import 'package:prbd_2526_a03/core/services/find_restaurant_service.dart';
import 'package:prbd_2526_a03/models/restaurant.dart';

final FindRestaurantService service = FindRestaurantService();


class RestaurantState {
  final List<Restaurant> restaurants;
  final bool isLoading;
  final String filter;

  const RestaurantState({
    this.restaurants = const [],
    this.isLoading = false,
    this.filter = '',
  });

  RestaurantState copyWith({
    List<Restaurant>? restaurants,
    bool? isLoading,
    String? filter,
  }) {
    return RestaurantState(
      restaurants: restaurants ?? this.restaurants,
      isLoading: isLoading ?? this.isLoading,
      filter: filter ?? this.filter,
    );
  }
}


class RestaurantProvider extends Notifier<RestaurantState> {

  @override
  RestaurantState build() {

    state = const RestaurantState(
      isLoading: true,
    );

    _loadRestaurants();

    return state;
  }

  Timer? _debounce;

  Future<void> onSearchChanged(String value) async {
    state = state.copyWith(
      filter: value,
    );

    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 400),
          () async {
        await _loadRestaurants();
      },
    );
  }

  Future<void> _loadRestaurants() async {
    state = state.copyWith(
      isLoading: true,
    );

    final restaurants =
    await service.getMatchingRestaurants(
      state.filter.trim(),
    );

    state = state.copyWith(
      restaurants: restaurants,
      isLoading: false,
    );
  }
}