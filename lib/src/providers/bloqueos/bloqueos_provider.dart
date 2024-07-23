import 'package:flutter/material.dart';
import 'package:pobla_app/config/environment/environment.dart';
import 'package:pobla_app/infrastructure/models/bloqueo.model.dart';
import 'package:pobla_app/src/utils/week_calculator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class BloqueosProvider with ChangeNotifier {
  List<BloqueoModel> bloqueos = [];
  bool loadingBloqueos = true;
  late IO.Socket _socket;
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  BloqueosProvider() {
    _initConfig();
  }

  void _initConfig() {
    const namespace = 'bloqueos';

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
      print('Conectado a /bloqueos');
      // loadingBloqueos = true;
      // notifyListeners();
      socket.emit('loadBloqueos', {
        'inicio': WeekCalculator.getWeekDates().inicio,
        'fin': WeekCalculator.getWeekDates().fin,
      });
    });

    socket.onDisconnect((_) {
      print('Desconectado de /bloqueos');
    });

    socket.on('loadedBloqueos', (data) {
      List<Map<String, dynamic>> bloqueosData =
          List<Map<String, dynamic>>.from(data);
      bloqueos = bloqueosData.map((r) => BloqueoModel.fromApi(r)).toList();
      loadingBloqueos = false;
      notifyListeners();
      print('Datos recibidos BLOQUEOS: $bloqueos');
    });

    // Escuchar evento de nueva reserva
    socket.on('nuevoBloqueo', (data) {
      BloqueoModel nuevoBloqueo = BloqueoModel.fromApi(data);
      bloqueos.add(nuevoBloqueo);
      notifyListeners();
      print('Nuevo bloqueo recibido: $nuevoBloqueo');
    });
  }

  void connect() {
    _socket.connect();
  }

  void disconnect() {
    _socket.disconnect();
  }
}
