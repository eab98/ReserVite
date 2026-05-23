
import 'package:prbd_2526_a03/core/services/security.dart';

class User {

  static final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final RegExp _digitRegex = RegExp(r'\d');
  static final RegExp _upperRegex = RegExp(r'[A-Z]');
  static final RegExp _lowerRegex = RegExp(r'[a-z]');
  static final RegExp _specialRegex = RegExp(r'[,;.:!?/$%&@#]');


  static String? validateEmailFormat(String? email) {
    if(email == null || email.isEmpty){
      return 'required';
    }
    return null;
  }
  //att ici, pas de validation async pour le login, la procedure login du back se charge des ces verif en interne MAIS il faut
  //les verifs null/empty en sync

  // static Future<String?> validateEmail(String? email) async {
  //   if(email == null || email.isEmpty) {
  //     return 'required';
  //   } else {
  //     var res = await Security.checkEmail(email: email.trim());
  //     return res ? null : 'no account linked to this email';
  //   }
  // }
  //
  static String? validatePasswordFormat(String? passwd){
    if(passwd == null || passwd.isEmpty){
      return 'required';
    }
    return null;
  }

  static String? validateFullNameFormat(String? fullName){
    if(fullName == null || fullName.isEmpty){
      return 'Veuillez entrer un nom complet';
    } else if (fullName.length < 3){
      return 'Le nom complet doit contenir au moins 3 caractères';
    } else {
      return null;
    }
  }

  static Future<String?> validateFullNameUnicity(String? fullName) async{

  }

  static String? validateEmailSignup(String? email){
    if(email == null || email.isEmpty){
      return 'Veuillez entrer un email';
    } else if(!_emailRegex.hasMatch(email)){
      return 'Veuillez entrer une adresse email valide';
    } else {
      return null;
    }
  }

  static Future<String?> validateEmailUnicity(String? email) async {

  }

  static String? validatePasswordSignup(String? password){
    if(password == null || password.isEmpty){
      return 'Veuillez entrer un mot de passe';
    } else if (password.length < 8){
      return 'Le mot de passe doit contenir au moins 8 caractères';
    } else if (!_digitRegex.hasMatch(password)){
      return 'Le mot de passe doit contenir au moins un chiffre';
    } else if (!_upperRegex.hasMatch(password)){
      return 'Le mot de passe doit contenir au moins une lettre majuscule';
    } else if (!_lowerRegex.hasMatch(password)){
      return 'Le mot de passe doit contenir au moins une lettre minuscule';
    } else if (!_specialRegex.hasMatch(password)){
      return 'Le mot de passe doit contenir au moins un caractère spécial';
    } else {
      return null;
    }
  }

  static String? validateMatchingPassword(String? passwordConfirm) {

  }




}