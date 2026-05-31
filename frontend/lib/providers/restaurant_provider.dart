import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a03/core/services/find_restaurant_service.dart';
import 'package:prbd_2526_a03/models/restaurant.dart';

class RestaurantState {
  final List<Restaurant> restaurants;
  final String filter;

  const RestaurantState({
    this.restaurants = const [],
    this.filter = '',
  });

  RestaurantState copyWith({
    List<Restaurant>? restaurants,
    String? filter,
  }) {
    return RestaurantState(
      restaurants: restaurants ?? this.restaurants,
      filter: filter ?? this.filter,
    );
  }
}


class RestaurantProvider extends Notifier<RestaurantState> {

  @override
  RestaurantState build() {

    state = const RestaurantState(
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
    );

    final restaurants =
    await FindRestaurantService.getMatchingRestaurants(
      state.filter.trim(),
    );

    state = state.copyWith(
      restaurants: restaurants,
    );
  }
}