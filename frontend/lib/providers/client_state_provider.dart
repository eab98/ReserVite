import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:prbd_2526_a03/core/services/reservation_services.dart';
import 'package:prbd_2526_a03/models/reservation.dart';
import 'package:prbd_2526_a03/providers/current_user_provider.dart';

class ClientState {
  final List<Reservation> reservations;
  final AsyncValue<Reservation>? currentReservationDetails;

  ClientState({required this.reservations, this.currentReservationDetails});

  ClientState copyWith({
     final List<Reservation>? reservations,
    final AsyncValue<Reservation>? currentReservationDetails
  })
  {
    return ClientState(reservations: reservations ?? this.reservations,
                            currentReservationDetails: currentReservationDetails ?? this.currentReservationDetails);

  }
}

final clientStateProvider =
  AsyncNotifierProvider<ClientStateNotifier, ClientState>(() => ClientStateNotifier());

class ClientStateNotifier extends AsyncNotifier<ClientState>{
  @override
  Future<ClientState> build() async {
    ref.watch(currentUserProvider);
    final list = await ReservationServices.getMyReservations();
    return ClientState(reservations: list);
  }

  Future<void> refresh() async{
    state = const AsyncLoading();
    try {
      final data = await ReservationServices.getMyReservations();
      state = AsyncData(ClientState(reservations: data));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> loadReservationDetails(int id) async {
    state = AsyncData(state.value!.copyWith(
      currentReservationDetails: AsyncLoading()
    ));
    
    try {
      final reservation = await ReservationServices.getReservationDetails(id);
      state = AsyncData(state.value!.copyWith(
        currentReservationDetails: AsyncData(reservation)
      ));
    } catch (e) {
      state = AsyncData(state.value!.copyWith(
        currentReservationDetails: AsyncError(e, StackTrace.current)
      ));
    }
  }

}