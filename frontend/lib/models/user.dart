
import 'package:prbd_2526_a03/security.dart';

class User {
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


}