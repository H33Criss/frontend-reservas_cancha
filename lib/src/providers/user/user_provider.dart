import 'package:flutter/material.dart';
import 'package:pobla_app/infrastructure/models/user.model.dart';
import 'package:pobla_app/infrastructure/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  bool renewingUser = true;
  final AuthRepository _authRepository = AuthRepository();
  ValueNotifier<User?> userListener = ValueNotifier<User?>(null);
  User? get user => userListener.value;
  // ⬇ Esto es el singleton de UserProvider, para devolver siempre la misma instancia(en main_router) ⬇
  static final UserProvider _singleton = UserProvider._internal();
  factory UserProvider() {
    return _singleton;
  }
  UserProvider._internal();
  // ⬆ Esto es el singleton de UserProvider, para devolver siempre la misma instancia(en main_router) ⬆

  Future<void> setUser(Map<String, dynamic> userData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userListener.value = User.fromApi(userData);
    await prefs.setString('idToken', userListener.value!.jwtToken);
    notifyListeners();
  }

  Future<void> clearUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('idToken');
    userListener.value = null;
    notifyListeners();
  }

  Future<void> renewUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? idToken = prefs.getString('idToken');

      if (idToken == null) {
        _handleRenewUserFailure();
        return;
      }

      final response = await _authRepository.renewToken(idToken);

      if (response == null) {
        // Failed to renew token
        await clearUser();
        _handleRenewUserFailure();
        return;
      }

      // Update user data with new token
      await setUser(response);
    } catch (error) {
      // Handle any exceptions
      print('Error renewing user: $error');
      await clearUser();
      _handleRenewUserFailure();
    } finally {
      renewingUser = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  void _handleRenewUserFailure() {
    renewingUser = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }
}
