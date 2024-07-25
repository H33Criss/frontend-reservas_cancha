import 'package:flutter/material.dart';
import 'package:pobla_app/config/environment/environment.dart';
import 'package:pobla_app/infrastructure/models/reserva.model.dart';
import 'package:pobla_app/src/helpers/reservas/reservas_helper.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:pobla_app/src/utils/week_calculator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
    final token = _userProvider.user?.jwtToken;

    // Si ya había una conexión de otro usuario, desconectamos
    if (_socket != null && _socket!.connected) {
      _clearAllListeners();
      _socket!.disconnect();
      _socket = null;
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
          .setExtraHeaders({'authentication': token})
          .build(),
    );
    _socket!.onConnect((_) {
      print('Conectado a Reservas');
    });

    _socket!.onDisconnect((_) {
      print('Desconectado a Reservas');
    });

    _socket!.onReconnect((_) {
      print('Reconectando a Reservas');
    });
  }

  void _clearAllListeners() {
    if (_socket != null) {
      _socket?.off('loadReservasOfAny');
      _socket?.off('loadReservasOfUser');
      _socket?.off('newReservaOfAny');
      _socket?.off('newReservaOfUser');
    }
  }

  void _registerListeners(List<ReservasEvent> events) {
    _clearAllListeners();
    for (var event in events) {
      switch (event) {
        case ReservasEvent.reservasOfAny:
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
            notifyListeners();
          });
          break;

        case ReservasEvent.newReservaOfAny:
          _socket!.on('newReservaOfAny', (data) {
            ReservaModel nuevaReserva = ReservaModel.fromApi(data);
            //No añadir reservas duplicadas
            final ReservaModel sentinel = ReservaModel.returnSentinel();
            final ReservaModel prevReserva = reservas.firstWhere(
              (r) => r.id == nuevaReserva.id,
              orElse: () => sentinel,
            );

            if (prevReserva != sentinel) return;
            reservas.add(nuevaReserva);
            reservas = ReservaHelper.ordenarReservas(reservas);
            notifyListeners();
          });
          break;
        case ReservasEvent.reservasOfUser:
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
            loadingReservas = false;
            notifyListeners();
          });
          break;

        case ReservasEvent.newReservaOfUser:
          _socket!.on('newReservaOfUser', (data) {
            ReservaModel nuevaReserva = ReservaModel.fromApi(data);
            //No añadir reservas duplicadas
            final ReservaModel sentinel = ReservaModel.returnSentinel();
            final ReservaModel prevReserva = reservasOfUser.firstWhere(
              (r) => r.id == nuevaReserva.id,
              orElse: () => sentinel,
            );

            if (prevReserva != sentinel) return;
            reservasOfUser.add(nuevaReserva);
            reservasOfUser = ReservaHelper.ordenarReservas(reservasOfUser);
            notifyListeners();
          });
          break;
        // Puedes añadir más casos para otros eventos aquí.
        default:
          print('Evento no manejado: $event');
      }
    }
  }

  void _clearListeners(events) {
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
    _socket?.connect();
    _registerListeners(events);
  }

  // Desconexión manual al servidor socket, pero en /reservas
  void disconnect(List<ReservasEvent> events) {
    try {
      _clearListeners(events);
      _socket?.disconnect();
    } catch (e) {
      throw Exception('Error Disconnect Socket');
    }
  }

  // Dejamos de escuchar si es que cambia el "user" de UserProvider
  @override
  void dispose() {
    _userProvider.userListener.removeListener(_updateSocket);
    _clearAllListeners();
    _socket
        ?.disconnect(); // Añadido para asegurarnos de que el socket se desconecta
    _socket = null;
    super.dispose();
  }
}
