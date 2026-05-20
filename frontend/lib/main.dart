import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prbd_2526_a03/login.dart';
import 'package:prbd_2526_a03/params.dart';


void main() async {
  await Params.init();
  await initializeDateFormatting('fr_FR', null);
  runApp(ProviderScope(
    child : MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    ),
  )
  );
}



