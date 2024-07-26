import 'package:flutter/material.dart';
import 'package:pobla_app/infrastructure/repositories/auth_repository.dart';
import 'package:pobla_app/src/providers/user/user_provider.dart';

UserProvider _userProvider = UserProvider();

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool authenticating = false;
  bool inProgressGoogle = false;
  bool inProgressEmailAndPassword = false;

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    authenticating = true;
    inProgressEmailAndPassword = true;
    notifyListeners();

    try {
      //!DELETE in production
      // await Future.delayed(const Duration(seconds: 1));
      final response =
          await _authRepository.loginWithEmailAndPassword(email, password);
      if (response == null) {
        throw Exception('Invalid credentials');
      }

      await _userProvider.setUser(response);
    } catch (e) {
      rethrow; // Re-lanzar la excepción original para otros errores
    } finally {
      authenticating = false;
      inProgressEmailAndPassword = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    authenticating = true;
    inProgressGoogle = true;
    notifyListeners();

    try {
      final response = await _authRepository.loginWithGoogle();
      if (response == null) {
        // throw Exception('Sesión cancelada');
        return;
      }

      await _userProvider.setUser(response);
    } catch (e) {
      rethrow;
    } finally {
      authenticating = false;
      inProgressGoogle = false;
      notifyListeners();
    }
  }

  Future<void> signOutUser() async {
    await _authRepository.signOutUser();
    await _userProvider.clearUser();
  }
}
