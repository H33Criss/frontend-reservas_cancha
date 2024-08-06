import 'package:flutter/material.dart';
import 'package:pobla_app/infrastructure/models/reserva.model.dart';
import 'package:pobla_app/src/providers/reservas/mixin/rest/rest_reserva_provider.dart';
import 'package:pobla_app/src/providers/reservas/mixin/socket/socket_reserva_provider.dart';

class ReservaProvider
    with ChangeNotifier, RestReservaProvider, SocketReservaProvider {
  bool loadingPagoReserva = false;
  bool dataFromLocal = false;

  void initialize() {
    initRest();
    initSocket();
  }

  Future<void> findReservaById(String id) async {
    loadingReserva = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    try {
      // Buscar en reservas del usuario
      final reservaUser = reservasProximas.firstWhere(
          (reserva) => reserva.id == id,
          orElse: () => ReservaModel.returnSentinel());
      if (reservaUser.id.isNotEmpty) {
        reservaOnDetail = reservaUser;
        dataFromLocal = true;
        getReservaFromApi(id); // Obtener datos más recientes en segundo plano
        return;
      }

      // Buscar en todas las reservas
      final reservaAll = reservasHorario.firstWhere(
          (reserva) => reserva.id == id,
          orElse: () => ReservaModel.returnSentinel());
      if (reservaAll.id.isNotEmpty) {
        reservaOnDetail = reservaAll;
        dataFromLocal = true;
        getReservaFromApi(id); // Obtener datos más recientes en segundo plano
        return;
      }

      await getReservaFromApi(id);
      dataFromLocal = false;
      // Realizar la solicitud al servidor
    } catch (e) {
      // Manejo de errores
      reservaOnDetail = null;
    } finally {
      loadingReserva = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }

  void clearReservaOnDetail() {
    reservaOnDetail = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  Future<void> getReservaFromApi(String id) async {
    loadingPagoReserva = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());

    try {
      final reservaFromApi = await getReservaById(id);
      reservaOnDetail = reservaFromApi;
    } catch (e) {
      print('Error al cargar el pago de la reserva $id');
    } finally {
      loadingPagoReserva = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    }
  }
}
