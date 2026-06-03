import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a03/core/services/reservation_services.dart';
import 'package:prbd_2526_a03/models/reservation.dart';

import '../core/services/restaurant_services.dart';
import '../models/restaurant.dart';
import 'current_user_provider.dart';

class ManagerState {
  final List<Restaurant> restaurants;
  final Restaurant? currentRestaurant;
  final List<Reservation> reservations;

  const ManagerState({
    this.restaurants = const [],
    this.reservations = const [],
    this.currentRestaurant,
  });

  ManagerState copyWith({
    List<Restaurant>? restaurants,
    List<Reservation>? reservations,
    Restaurant? currentRestaurant,
  }) {
    return ManagerState(
      restaurants: restaurants ?? this.restaurants,
      reservations: reservations ?? this.reservations,
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

  Future<void> selectRestaurant(Restaurant restaurant) async {
    final previous = state.value;

    if (previous == null) return;

    state = AsyncData(
      previous.copyWith(
        currentRestaurant: restaurant,
        reservations: const [],
      ),
    );

    try {
      final reservations =
      await ReservationServices
          .getAllReservationsForRestaurant(
        restaurant.id,
      );

      final current = state.value ?? previous;

      state = AsyncData(
        current.copyWith(
          currentRestaurant: restaurant,
          reservations: reservations,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshReservationsForCurrentRestaurant() async {
    final previous = state.value;

    if (previous == null) return;

    final restaurant = previous.currentRestaurant;

    if (restaurant == null) return;

    try {
      final reservations =
      await ReservationServices
          .getAllReservationsForRestaurant(
        restaurant.id,
      );

      state = AsyncData(
        previous.copyWith(
          reservations: reservations,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}