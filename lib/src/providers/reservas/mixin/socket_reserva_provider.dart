import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pobla_app/config/environment/environment.dart';
import 'package:pobla_app/infrastructure/models/reserva.model.dart';
import 'package:pobla_app/src/helpers/reservas/reservas_helper.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:pobla_app/src/utils/week_calculator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

UserProvider _userProvider = UserProvider();

enum ReservasEvent {
  reservasHorario,
  newReservaHorario,
  reservasProximas,
  newReservaProxima,
  specificReserva,
  // Otros eventos que puedas tener
}

//mixin, porque se separo la logica de socket y rest en 2 archivos
//para conformar 1 provider, llamado "ReservaProvider"
mixin SocketReservaProvider on ChangeNotifier {
  //Esta reserva es la se estan viendo en el algun detalle
  ReservaModel? reservaOnDetail;
  List<ReservaModel> reservasHorario = [];
  List<ReservaModel> reservasProximas = [];
  bool loadingReservasHorario = false;
  bool loadingReservasProximas = false;
  // bool connectionTimeOut = false;
  io.Socket? _socket;
  io.Socket? get socket => _socket;

  //Gestiona el connection-timeout de los eventos
  final Map<ReservasEvent, Timer?> _timers = {};
  final Map<ReservasEvent, bool> connectionTimeouts = {
    ReservasEvent.reservasHorario: false,
    ReservasEvent.reservasProximas: false,
  };

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
    _socket = io.io(
      '${Environment.apiSocketUrl}/$namespace',
      io.OptionBuilder()
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

  void _registerListeners(List<ReservasEvent> events,
      {List<String>? reservaIds}) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case ReservasEvent.reservasHorario:
          _handleReservasHorario();
          break;

        case ReservasEvent.newReservaHorario:
          _socket!.on('newReservaHorario', (data) {
            ReservaModel nuevaReserva = ReservaModel.fromApi(data);
            final ReservaModel sentinel = ReservaModel.returnSentinel();
            final ReservaModel prevReserva = reservasHorario.firstWhere(
              (r) => r.id == nuevaReserva.id,
              orElse: () => sentinel,
            );

            if (prevReserva != sentinel) return;
            reservasHorario.add(nuevaReserva);
            reservasHorario = ReservaHelper.ordenarReservas(reservasHorario);
            WidgetsBinding.instance
                .addPostFrameCallback((_) => notifyListeners());
          });
          break;
        case ReservasEvent.reservasProximas:
          _handleReservasProximas();
          break;

        case ReservasEvent.newReservaProxima:
          _socket!.on('newReservaProxima', (data) {
            ReservaModel nuevaReserva = ReservaModel.fromApi(data);
            final ReservaModel sentinel = ReservaModel.returnSentinel();
            final ReservaModel prevReserva = reservasProximas.firstWhere(
              (r) => r.id == nuevaReserva.id,
              orElse: () => sentinel,
            );

            if (prevReserva != sentinel) return;
            reservasProximas.add(nuevaReserva);
            reservasProximas = ReservaHelper.ordenarReservas(reservasProximas);
            WidgetsBinding.instance
                .addPostFrameCallback((_) => notifyListeners());
          });
          break;
        case ReservasEvent.specificReserva:
          if (reservaIds == null) return;

          _handleSpecificReservas(reservaIds);
        default:
          print('Evento no manejado: $event');
      }
    }
  }

  void _clearAllListeners() {
    if (_socket != null) {
      _socket?.off('loadReservasHorario');
      _socket?.off('loadReservasProximas');
      _socket?.off('newReservaHorario');
      _socket?.off('newReservaProxima');
    }
  }

  void _clearListeners(events, {List<String>? reservaIds}) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case ReservasEvent.reservasHorario:
          _socket?.off('loadReservasHorario');
          break;
        case ReservasEvent.reservasProximas:
          _socket?.off('loadReservasProximas');
          break;
        case ReservasEvent.newReservaHorario:
          _socket?.off('newReservaHorario');
          break;
        case ReservasEvent.newReservaProxima:
          _socket?.off('newReservaProxima');
          break;
        case ReservasEvent.specificReserva:
          if (reservaIds == null) return;
          for (var id in reservaIds) {
            _socket?.off('reserva-$id');
          }
          break;
      }
    }
  }

  // Conexión manual al servidor socket, pero en /reservas
  void connect(List<ReservasEvent> events, {List<String>? reservaIds}) {
    _clearListeners(events, reservaIds: reservaIds);
    _registerListeners(events, reservaIds: reservaIds);
  }

  // Desconexión manual al servidor socket, pero en /reservas
  void disconnect(List<ReservasEvent> events, {List<String>? reservaIds}) {
    _clearListeners(events, reservaIds: reservaIds);
  }

  void _disposeSocket() {
    _clearAllListeners();
    _socket?.disconnect();
    _socket = null;
    reservasProximas.clear();
    reservasHorario.clear();
  }

  void _handleReservasProximas() {
    loadingReservasProximas = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    _socket!.emit('reservasProximas', {
      'userId': _userProvider.user?.id ?? 'no id',
      'today': WeekCalculator.formatDate(DateTime.now()),
    });
    //Timer de connection-timeout
    _timers[ReservasEvent.reservasProximas] =
        Timer(const Duration(seconds: 10), () {
      if (loadingReservasProximas) {
        loadingReservasProximas = false;
        connectionTimeouts[ReservasEvent.reservasProximas] = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
        print('Error: El servidor no respondió a tiempo');
      }
    });

    _socket!.on('loadReservasProximas', (data) {
      _timers[ReservasEvent.reservasProximas]
          ?.cancel(); //Cancelar Timer de connection-timeout
      List<Map<String, dynamic>> reservasData =
          List<Map<String, dynamic>>.from(data);
      reservasProximas.clear();
      reservasProximas =
          reservasData.map((r) => ReservaModel.fromApi(r)).toList();
      loadingReservasProximas = false;
      connectionTimeouts[ReservasEvent.reservasProximas] = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
  }

  void _handleReservasHorario() {
    loadingReservasHorario = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    _socket!.emit('reservasHorario', {
      'inicio': WeekCalculator.getWeekDates().inicio,
      'fin': WeekCalculator.getWeekDates().fin,
    });
    //Timer de connection-timeout
    _timers[ReservasEvent.reservasHorario] =
        Timer(const Duration(seconds: 10), () {
      if (loadingReservasHorario) {
        loadingReservasHorario = false;
        connectionTimeouts[ReservasEvent.reservasHorario] = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
        print('Error: El servidor no respondió a tiempo');
      }
    });
    _socket!.on('loadReservasHorario', (data) {
      _timers[ReservasEvent.reservasHorario]
          ?.cancel(); //Cancelar Timer de connection-timeout
      List<Map<String, dynamic>> reservasData =
          List<Map<String, dynamic>>.from(data);
      reservasHorario =
          reservasData.map((r) => ReservaModel.fromApi(r)).toList();
      loadingReservasHorario = false;
      connectionTimeouts[ReservasEvent.reservasHorario] = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
  }

  void _handleSpecificReservas(List<String> reservaIds) {
    for (var id in reservaIds) {
      _socket!.on('reserva-$id', (data) {
        print('Reserva específica recibida: $id');
        // Procesa la data según sea necesario
        ReservaModel updatedReserva = ReservaModel.fromApi(data);
        // Actualizar en reservasHorario
        int index = reservasHorario.indexWhere((reserva) => reserva.id == id);
        if (index != -1) {
          reservasHorario[index] = ReservaModel.updateFromModel(updatedReserva);
        }

        // Actualizar en reservasProximas
        index = reservasProximas.indexWhere((reserva) => reserva.id == id);
        if (index != -1) {
          reservasProximas[index] =
              ReservaModel.updateFromModel(updatedReserva);
        }
        if (reservaOnDetail != null) {
          reservaOnDetail = updatedReserva;
        }

        // Notificar a los listeners sobre los cambios
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      });
    }
  }
}
