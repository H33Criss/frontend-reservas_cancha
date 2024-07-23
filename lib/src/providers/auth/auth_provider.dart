import 'package:flutter/foundation.dart';
import 'package:pobla_app/infrastructure/repositories/auth_repository.dart';

enum AuthStatus {
  authenticated,
  authenticating,
  notAuthenticated,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  //Errores ocurridos durante el login
  List<String> errors = [];
  ValueNotifier<AuthStatus> status =
      ValueNotifier<AuthStatus>(AuthStatus.notAuthenticated);

  Future<void> loginWithGoogle() async {
    status.value = AuthStatus.authenticating;
    notifyListeners();

    final response = await _authRepository.loginWithGoogle();
    //Significa que el usuario cancelo el inicio de sesión
    if (response == null) {
      status.value = AuthStatus.notAuthenticated;
      notifyListeners();
      return;
    }
    print(response);
    status.value = AuthStatus.authenticated;
    notifyListeners();
    // if (response.userCredential != null &&
    //     response.userCredential?.user != null) {
    //   errors.clear();
    // } else {
    //   if (!errors.contains('Ocurrio un error, intenta de nuevo.')) {
    //     errors.add('Ocurrio un error, intenta de nuevo.');
    //   }
    //   status.value = AuthStatus.notAuthenticated;
    // }
    // notifyListeners();
  }
}
