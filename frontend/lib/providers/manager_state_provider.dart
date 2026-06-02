import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/restaurant_services.dart';
import '../models/restaurant.dart';
import 'current_user_provider.dart';

class ManagerState {
  final List<Restaurant> restaurants;
  final Restaurant? currentRestaurant;

  const ManagerState({
    this.restaurants = const [],
    this.currentRestaurant,
  });

  ManagerState copyWith({
    List<Restaurant>? restaurants,
    Restaurant? currentRestaurant,
  }) {
    return ManagerState(
      restaurants: restaurants ?? this.restaurants,
      currentRestaurant: currentRestaurant ?? this.currentRestaurant,
    );
  }
}

final managerStateProvider =
AsyncNotifierProvider<ManagerStateNotifier, ManagerState>(
  ManagerStateNotifier.new,
);

class ManagerStateNotifier extends AsyncNotifier<ManagerState> {
  @override
  Future<ManagerState> build() async {
    final user =
    await ref.watch(currentUserProvider.future);

    if (user == null) {
      return const ManagerState();
    }

    if (!user.isManager) {
      throw Exception(
        'Access denied: manager role required',
      );
    }

    final restaurants =
    await RestaurantServices.getMyRestaurants();

    return ManagerState(
      restaurants: restaurants
    );
  }

  Future<void> refreshRestaurants() async {
    final previous = state.value;

    if (previous == null) return;

    try {
      final restaurants =
      await RestaurantServices.getMyRestaurants();

      state = AsyncData(
        previous.copyWith(
          restaurants: restaurants,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void selectRestaurant(Restaurant restaurant) {
    final previous = state.value;

    if (previous == null) return;

    state = AsyncData(
      previous.copyWith(
        currentRestaurant: restaurant,
      ),
    );
  }
}