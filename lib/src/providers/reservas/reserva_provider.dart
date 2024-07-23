import 'package:flutter/material.dart';
import 'package:pobla_app/src/providers/reservas/mixin/rest_reserva_provider.dart';
import 'package:pobla_app/src/providers/reservas/mixin/socket_reserva_provider.dart';

class ReservaProvider
    with ChangeNotifier, RestReservaProvider, SocketReservaProvider {
  ReservaProvider() {
    initSocket();
  }
}
