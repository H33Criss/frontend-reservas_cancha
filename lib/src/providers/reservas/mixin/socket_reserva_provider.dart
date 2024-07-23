import 'package:flutter/material.dart';
import 'package:pobla_app/config/environment/environment.dart';
import 'package:pobla_app/infrastructure/models/reserva.model.dart';
import 'package:pobla_app/src/utils/week_calculator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

mixin SocketReservaProvider on ChangeNotifier {
  List<ReservaModel> reservas = [];
  bool loadingReservas = true;
  late IO.Socket _socket;
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  void initSocket() {
    const namespace = 'reservas';

    _socket = IO.io(
      '${Environment.apiSocketUrl}/$namespace',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect() // Disable auto-connection
          .setExtraHeaders({
            'authentication':
                'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImFjNzUzMjk2LTZkYjUtNDg0Zi04NzAyLTA3NTA0MTQ5Mzg2MyIsImlhdCI6MTcyMTUxMzcyNSwiZXhwIjoxNzIxNTIwOTI1fQ.0QV65trlvWhno2UdqSHnmEMP8CNhWdU3FSgWQXsJCN4',
          })
          .build(),
    );

    socket.onConnect((_) {
      print('Conectado a /reservas');
      // loadingReservas = true;
      // notifyListeners();
      socket.emit('loadReservas', {
        'inicio': WeekCalculator.getWeekDates().inicio,
        'fin': WeekCalculator.getWeekDates().fin,
      });
    });

    socket.onDisconnect((_) {
      print('Desconectado de /reservas');
    });

    socket.on('loadedReservas', (data) {
      List<Map<String, dynamic>> reservasData =
          List<Map<String, dynamic>>.from(data);
      reservas = reservasData.map((r) => ReservaModel.fromApi(r)).toList();
      loadingReservas = false;
      notifyListeners();
      print('Datos recibidos RESERVAS: $reservas');
    });

    socket.on('nuevaReserva', (data) {
      ReservaModel nuevaReserva = ReservaModel.fromApi(data);
      reservas.add(nuevaReserva);
      notifyListeners();
      print('Nueva reserva recibida: $nuevaReserva');
    });
  }

  void connect() {
    _socket.connect();
  }

  void disconnect() {
    _socket.disconnect();
  }
}
