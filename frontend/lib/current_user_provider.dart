import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a03/security.dart';
import 'package:prbd_2526_a03/params.dart';
import 'package:jwt_decoder/jwt_decoder.dart';


final currentUserProvider = AsyncNotifierProvider<CurrentUserNotifier, String?>(
    () => CurrentUserNotifier(),
);

class CurrentUserNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    state = AsyncData(Params.getValue('token'));
    return state.value;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      var token = await Security.login(email, password);
       Params.setValue('token', token);
      state = AsyncData(token);
    }catch(e){
      state = AsyncError(
        "Something went wrong!\nPlease try again later.\n" + StackTrace.current.toString(),
        StackTrace.current,
      );
    }
  }
}