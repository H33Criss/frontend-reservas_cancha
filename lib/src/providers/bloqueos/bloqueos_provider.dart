import 'package:flutter/material.dart';
import 'package:pobla_app/config/environment/environment.dart';
import 'package:pobla_app/infrastructure/models/bloqueo.model.dart';
import 'package:pobla_app/src/providers/user/user_provider.dart';
import 'package:pobla_app/src/utils/week_calculator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

UserProvider _userProvider = UserProvider();

class BloqueosProvider with ChangeNotifier {
  List<BloqueoModel> bloqueos = [];
  bool loadingBloqueos = false;

  IO.Socket? _socket;
  IO.Socket? get socket => _socket;

  initSocket() {
    _userProvider.userListener.addListener(_updateSocket);
  }

  void _updateSocket() {
    //Token del nuevo usuario en sesión
    final token = _userProvider.user?.jwtToken;

    // Si ya había una conexión de otro usuario, desconectamos
    if (_socket != null && _socket!.connected) {
      _disposeSocket();
    }
    // Si no hay token, no creamos una nueva conexión
    if (token == null) return;
    const namespace = 'bloqueos';

    _socket = IO.io(
      '${Environment.apiSocketUrl}/$namespace',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect() // Disable auto-connection
          .setExtraHeaders({
            'authentication': _userProvider.userListener.value!.jwtToken,
          })
          .build(),
    );

    _socket!.onConnect((_) {
      print('Conectado a Bloqueos - ${_socket?.id ?? 'NO id'}');
    });

    _socket!.onDisconnect((_) {
      print('Desconectado de Bloqueos');
    });

    _socket!.connect();
  }

  void _clearListeners() {
    _socket?.off('loadedBloqueos');
    _socket?.off('nuevoBloqueo');
  }

  void _registerListeners() {
    loadingBloqueos = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    //Solicitar todos los bloqueos por rango de fechas
    _socket!.emit('loadBloqueos', {
      'inicio': WeekCalculator.getWeekDates().inicio,
      'fin': WeekCalculator.getWeekDates().fin,
    });
    //Recibir todos los bloqueos del rango de fechas
    _socket!.on('loadedBloqueos', (data) {
      List<Map<String, dynamic>> bloqueosData =
          List<Map<String, dynamic>>.from(data);
      bloqueos = bloqueosData.map((r) => BloqueoModel.fromApi(r)).toList();
      loadingBloqueos = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
    // Escuchar evento de un nuevo bloqueo
    _socket!.on('nuevoBloqueo', (data) {
      BloqueoModel nuevoBloqueo = BloqueoModel.fromApi(data);
      bloqueos.add(nuevoBloqueo);
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
  }

  void connect() {
    _registerListeners();
  }

  void disconnect() {
    _clearListeners();
  }

  void _disposeSocket() {
    print('Dispose socket Bloqueos');
    _clearListeners();
    _socket?.disconnect();
    _socket = null;
  }
}
