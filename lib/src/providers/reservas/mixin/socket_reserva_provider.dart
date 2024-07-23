// socket_reserva_provider.dart
import 'package:flutter/material.dart';
import 'package:pobla_app/config/environment/environment.dart';
import 'package:pobla_app/infrastructure/models/reserva.model.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:pobla_app/src/utils/week_calculator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

//mixin, porque se separo la logica de socket y rest en 2 archivos
//para conformar 1 provider, llamado "ReservaProvider"
mixin SocketReservaProvider on ChangeNotifier {
  List<ReservaModel> reservas = [];
  bool loadingReservas = true;
  IO.Socket? _socket;
  IO.Socket? get socket => _socket;
  late UserProvider _userProvider;

  void initSocket(UserProvider userProvider) {
    _userProvider = userProvider;
    _updateSocket();
    //Para que cada vez que el usuario cambie, creo un nuevo socket, con otro token
    _userProvider.userListener.addListener(_updateSocket);
  }

  void _updateSocket() {
    //Token del nuevo usuario en sesión
    final token = _userProvider.userListener.value?.jwtToken;

    // Si ya había una conexión de otro usuario, desconectamos
    if (_socket != null && _socket!.connected) {
      _socket!.disconnect();
    }

    // Conexión con el servidor, pero para el namespace reservas
    const namespace = 'reservas';
    _socket = IO.io(
      '${Environment.apiSocketUrl}/$namespace',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'authentication': token})
          .build(),
    );

    _socket!.onConnect((_) {
      _socket!.emit('loadReservas', {
        'inicio': WeekCalculator.getWeekDates().inicio,
        'fin': WeekCalculator.getWeekDates().fin,
      });
    });

    _socket!.onDisconnect((_) {
      // print('Desconectado de Reservas');
    });

    _socket!.on('loadedReservas', (data) {
      List<Map<String, dynamic>> reservasData =
          List<Map<String, dynamic>>.from(data);
      reservas = reservasData.map((r) => ReservaModel.fromApi(r)).toList();
      loadingReservas = false;
      notifyListeners();
    });

    _socket!.on('nuevaReserva', (data) {
      ReservaModel nuevaReserva = ReservaModel.fromApi(data);
      reservas.add(nuevaReserva);
      notifyListeners();
    });
  }

  // Conexión manual al servidor socket, pero en /reservas
  void connect() {
    _socket?.connect();
  }

  // Desconexión manual al servidor socket, pero en /reservas
  void disconnect() {
    _socket?.disconnect();
  }

  // Dejamos de escuchar si cambia el "user" de UserProvider
  @override
  void dispose() {
    _userProvider.userListener.removeListener(_updateSocket);
    super.dispose();
  }
}
