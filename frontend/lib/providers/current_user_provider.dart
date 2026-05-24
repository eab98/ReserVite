import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prbd_2526_a03/core/services/security.dart';
import 'package:prbd_2526_a03/core/tools/params.dart';
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
        "Something went wrong!\nPlease try again later.",
        StackTrace.current,
      );
    }
  }

  Future<void> resetDataBase() async {
    state = const AsyncLoading();
    try {
      await Security.resetDataBase();
      Params.clearAll();
      state = const AsyncData(null);
    } catch (e){
      state = AsyncError("Could not reset data base.\nPlease try again later.", StackTrace.current);
    }

  }

  Future<void> signup(String fullName, String email, String password, String? phone) async {
    state = const AsyncLoading();
    try{
      await Security.signup(fullName, email, password, phone);
      var token = await Security.login(email, password);
      Params.setValue('token', token);
      state = AsyncData(token);
    } catch (e){
      state = AsyncError('"Something went wrong!\nPlease try again later."', StackTrace.current);
    }
  }

  Future<void> logout() async {
    await Params.clearAll();
    state = AsyncData(null);
  }

}