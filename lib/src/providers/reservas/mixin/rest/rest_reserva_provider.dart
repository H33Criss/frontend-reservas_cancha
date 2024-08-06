import 'package:flutter/material.dart';
import 'package:pobla_app/infrastructure/models/reserva.model.dart';
import 'package:pobla_app/infrastructure/repositories/reservas_repository.dart';
import 'package:pobla_app/src/providers/user/user_provider.dart';

UserProvider _userProvider = UserProvider();
//mixin, porque se separo la logica de socket y rest en 2 archivos
//para conformar 1 provider, llamado "ReservaProvider"
mixin RestReservaProvider on ChangeNotifier {
  late ReservasRepository _reservasRepository;

  bool creatingReserva = false;
  bool loadingReserva = false;

  void initRest() {
    _reservasRepository = ReservasRepository(_userProvider);
  }

  Future<void> editReservas() async {}
  Future<void> cancelReserva(String idReserva) async {}

  Future<void> addReserva(Map<String, dynamic> reservaData) async {
    creatingReserva = true;
    notifyListeners();
    try {
      await _reservasRepository.addReserva(reservaData);
    } catch (error) {
      print('Error al añadir reserva: $error');
    } finally {
      creatingReserva = false;
      notifyListeners();
    }
  }

  Future<ReservaModel?> getReservaById(String id) async {
    try {
      final reserva = await _reservasRepository.getReservaById(id);
      return reserva;
    } catch (error) {
      print('Error al obtener reserva: $error');
      return null;
    }
  }
}
