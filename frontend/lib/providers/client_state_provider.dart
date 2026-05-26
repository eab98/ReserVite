import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a03/core/services/reservation_services.dart';
import 'package:prbd_2526_a03/models/reservation.dart';
import 'package:prbd_2526_a03/providers/current_user_provider.dart';

final clientStateProvider =
  AsyncNotifierProvider<ClientStateNotifier, List<Reservation>>(() => ClientStateNotifier());

class ClientStateNotifier extends AsyncNotifier<List<Reservation>>{
  @override
  Future<List<Reservation>> build() async {
    ref.watch(currentUserProvider);
    return await ReservationServices.getMyReservations();
  }

  Future<void> refresh() async{
    state = const AsyncLoading();
    try {
      final data = await ReservationServices.getMyReservations();
      state = AsyncData(data);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

}