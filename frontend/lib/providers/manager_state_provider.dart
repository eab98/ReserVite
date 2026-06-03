import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a03/core/services/customer_services.dart';
import 'package:prbd_2526_a03/core/services/reservation_services.dart';
import 'package:prbd_2526_a03/core/services/tables_service.dart';
import 'package:prbd_2526_a03/models/customer.dart';
import 'package:prbd_2526_a03/models/reservation.dart';
import 'package:prbd_2526_a03/models/tables.dart';
import 'package:prbd_2526_a03/providers/reference_time_provider.dart';
import 'package:prbd_2526_a03/providers/simulated_time_provider.dart';

import '../core/services/restaurant_services.dart';
import '../models/restaurant.dart';
import 'current_user_provider.dart';

class ManagerState {
  final List<Restaurant> restaurants;
  final Restaurant? currentRestaurant;
  final Reservation? currentReservation;
  final List<Reservation> reservations;
  final Customer? currentCustomer;
  final List<Tables> currentTables;
  final List<Tables> availableTables;

  const ManagerState({
    this.restaurants = const [],
    this.reservations = const [],
    this.currentRestaurant,
    this.currentReservation,
    this.currentCustomer,
    this.currentTables = const [],
    this.availableTables = const []
  });

  ManagerState copyWith({
    List<Restaurant>? restaurants,
    List<Reservation>? reservations,
    Restaurant? currentRestaurant,
    Reservation? currentReservation,
    Customer? currentCustomer,
    List<Tables>? currentTables,
    List<Tables>? availableTables
  }) {
    return ManagerState(
      restaurants: restaurants ?? this.restaurants,
      reservations: reservations ?? this.reservations,
      currentRestaurant: currentRestaurant ?? this.currentRestaurant,
      currentReservation: currentReservation ?? this.currentReservation,
      currentCustomer: currentCustomer ?? this.currentCustomer,
      currentTables: currentTables ?? this.currentTables,
      availableTables: availableTables ?? this.availableTables
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
    ref.watch(simulatedTimeProvider);
    final user = await ref.watch(currentUserProvider.future);

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

  Future<void> selectReservation(Reservation reservation) async {
    final previous = state.value;

    if (previous == null) return;

    state = AsyncData(previous.copyWith(currentReservation: reservation));

    try {
      final customer = await CustomerServices.getUserByName(reservation.clientName!);
      final tables = await TablesService.getTablesForReservation(reservation.id);
      final availableTables = await TablesService.getAllAvailableTables(reservation.id);

      final current = state.value ?? previous;

      state = AsyncData(
        current.copyWith(
            currentReservation: reservation,
            currentCustomer: customer,
            currentTables: tables,
            availableTables: availableTables)
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refreshReservationDetails() async {
    final previous = state.value;
    if (previous == null) return;

    final reservation = previous.currentReservation;

    if (reservation == null) return;

    try {
      final customer = await CustomerServices.getUserByName(reservation.clientName!);
      final tables = await TablesService.getTablesForReservation(reservation.id);
      final availableTables = await TablesService.getAllAvailableTables(reservation.id);

      final current = state.value ?? previous;

      state = AsyncData(
          current.copyWith(
              currentReservation: reservation,
              currentCustomer: customer,
              currentTables: tables,
              availableTables: availableTables)
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

  Future<void> refreshAvailableTablesForCurrentReservation() async {
    final previous = state.value;
    if (previous == null) return;

    final reservation = previous.currentReservation;
    if (reservation == null) return;

    try {
      final availableTables = await TablesService.getAllAvailableTables(reservation.id);

      final currentTables = await TablesService.getTablesForReservation(reservation.id);

      state = AsyncData(
        previous.copyWith(
          availableTables: availableTables,
          currentTables: currentTables,
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}