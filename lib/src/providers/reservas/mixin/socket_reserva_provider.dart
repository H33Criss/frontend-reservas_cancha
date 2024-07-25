import 'package:flutter/material.dart';
import 'package:pobla_app/config/environment/environment.dart';
import 'package:pobla_app/infrastructure/models/reserva.model.dart';
import 'package:pobla_app/src/helpers/reservas/reservas_helper.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:pobla_app/src/utils/week_calculator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

UserProvider _userProvider = UserProvider();

enum ReservasEvent {
  reservasOfAny,
  newReservaOfAny,
  reservasOfUser,
  newReservaOfUser
  // Otros eventos que puedas tener
}

//mixin, porque se separo la logica de socket y rest en 2 archivos
//para conformar 1 provider, llamado "ReservaProvider"
mixin SocketReservaProvider on ChangeNotifier {
  List<ReservaModel> reservas = [];
  List<ReservaModel> reservasOfUser = [];
  bool loadingReservas = false;
  bool loadingReservasOfUser = false;
  IO.Socket? _socket;
  IO.Socket? get socket => _socket;

  void initSocket() {
    //Para que cada vez que el usuario cambie, creo un nuevo socket, con otro token
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

    // Conexión con el servidor, pero para el namespace reservas
    const namespace = 'reservas';
    _socket = IO.io(
      '${Environment.apiSocketUrl}/$namespace',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .disableForceNew()
          .disableForceNewConnection()
          .setExtraHeaders({'authentication': token})
          .build(),
    );
    _socket!.onConnect((_) {
      print('Conectado a Reservas - ${_socket?.id ?? 'NO id'}');
    });

    _socket!.onDisconnect((_) {
      print('Desconectado de Reservas - ${_socket?.id ?? 'NO id'}');
    });

    _socket!.onReconnect((_) {
      print('Reconectando a Reservas - ${_socket?.id ?? 'NO id'}');
    });

    _socket?.connect();
  }

  void _registerListeners(List<ReservasEvent> events) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case ReservasEvent.reservasOfAny:
          loadingReservas = true;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => notifyListeners());
          _socket!.emit('reservasOfAny', {
            'inicio': WeekCalculator.getWeekDates().inicio,
            'fin': WeekCalculator.getWeekDates().fin,
          });
          _socket!.on('loadReservasOfAny', (data) {
            List<Map<String, dynamic>> reservasData =
                List<Map<String, dynamic>>.from(data);
            reservas =
                reservasData.map((r) => ReservaModel.fromApi(r)).toList();
            loadingReservas = false;
            WidgetsBinding.instance
                .addPostFrameCallback((_) => notifyListeners());
          });
          break;

        case ReservasEvent.newReservaOfAny:
          _socket!.on('newReservaOfAny', (data) {
            ReservaModel nuevaReserva = ReservaModel.fromApi(data);
            final ReservaModel sentinel = ReservaModel.returnSentinel();
            final ReservaModel prevReserva = reservas.firstWhere(
              (r) => r.id == nuevaReserva.id,
              orElse: () => sentinel,
            );

            if (prevReserva != sentinel) return;
            reservas.add(nuevaReserva);
            reservas = ReservaHelper.ordenarReservas(reservas);
            WidgetsBinding.instance
                .addPostFrameCallback((_) => notifyListeners());
          });
          break;
        case ReservasEvent.reservasOfUser:
          loadingReservasOfUser = true;
          WidgetsBinding.instance
              .addPostFrameCallback((_) => notifyListeners());
          _socket!.emit('reservasOfUser', {
            'userId': _userProvider.user?.id ?? 'no id',
            'today': WeekCalculator.formatDate(DateTime.now()),
          });
          _socket!.on('loadReservasOfUser', (data) {
            List<Map<String, dynamic>> reservasData =
                List<Map<String, dynamic>>.from(data);
            reservasOfUser.clear();
            reservasOfUser =
                reservasData.map((r) => ReservaModel.fromApi(r)).toList();
            loadingReservasOfUser = false;
            WidgetsBinding.instance
                .addPostFrameCallback((_) => notifyListeners());
          });
          break;

        case ReservasEvent.newReservaOfUser:
          _socket!.on('newReservaOfUser', (data) {
            ReservaModel nuevaReserva = ReservaModel.fromApi(data);
            final ReservaModel sentinel = ReservaModel.returnSentinel();
            final ReservaModel prevReserva = reservasOfUser.firstWhere(
              (r) => r.id == nuevaReserva.id,
              orElse: () => sentinel,
            );

            if (prevReserva != sentinel) return;
            reservasOfUser.add(nuevaReserva);
            reservasOfUser = ReservaHelper.ordenarReservas(reservasOfUser);
            WidgetsBinding.instance
                .addPostFrameCallback((_) => notifyListeners());
          });
          break;
        default:
          print('Evento no manejado: $event');
      }
    }
  }

  void _clearAllListeners() {
    if (_socket != null) {
      _socket?.off('loadReservasOfAny');
      _socket?.off('loadReservasOfUser');
      _socket?.off('newReservaOfAny');
      _socket?.off('newReservaOfUser');
    }
  }

  void _clearListeners(events) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case ReservasEvent.reservasOfAny:
          _socket?.off('loadReservasOfAny');
          break;
        case ReservasEvent.reservasOfUser:
          _socket?.off('loadReservasOfUser');
          break;
        case ReservasEvent.newReservaOfAny:
          _socket?.off('newReservaOfAny');
          break;
        case ReservasEvent.newReservaOfUser:
          _socket?.off('newReservaOfUser');
          break;
      }
    }
  }

  // Conexión manual al servidor socket, pero en /reservas
  void connect(List<ReservasEvent> events) {
    _clearListeners(events);
    _registerListeners(events);
  }

  // Desconexión manual al servidor socket, pero en /reservas
  void disconnect(List<ReservasEvent> events) {
    _clearListeners(events);
  }

  void _disposeSocket() {
    print('Dispose socket Reservas');
    _clearAllListeners();
    _socket?.disconnect();
    _socket = null;
  }
}
