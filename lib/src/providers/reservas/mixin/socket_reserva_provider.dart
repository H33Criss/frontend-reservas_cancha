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

class SocketEvents {
  //Piden Data
  static const String reservasHorario = 'reservasHorario';
  static const String reservasProximas = 'reservasProximas';
  //Reciben data
  static const String loadReservasHorario = 'loadReservasHorario';
  static const String newReservaHorario = 'newReservaHorario';
  static const String loadReservasProximas = 'loadReservasProximas';
  static const String newReservaProxima = 'newReservaProxima';
  static const String specificReserva = 'reserva-'; // Se usará con un ID
}

mixin SocketReservaProvider on ChangeNotifier {
  ReservaModel? reservaOnDetail;
  List<ReservaModel> reservasHorario = [];
  List<ReservaModel> reservasProximas = [];
  bool loadingReservasHorario = false;
  bool loadingReservasProximas = false;
  io.Socket? _socket;
  io.Socket? get socket => _socket;

  final Map<ReservasEvent, Timer?> _timers = {};
  final Map<ReservasEvent, bool> connectionTimeouts = {
    ReservasEvent.reservasHorario: false,
    ReservasEvent.reservasProximas: false,
  };

  void initSocket() {
    _userProvider.userListener.addListener(_updateSocket);
  }

  void _updateSocket() {
    final token = _userProvider.user?.jwtToken;
    if (_socket != null && _socket!.connected) {
      _disposeSocket();
    }
    if (token == null) return;

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
    _socket!.onConnect((_) {});
    _socket!.onDisconnect((_) {});
    _socket!.onReconnect((_) {});
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
          _socket!.on(SocketEvents.newReservaHorario, (data) {
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
          _socket!.on(SocketEvents.newReservaProxima, (data) {
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
          break;

        default:
          print('Evento no manejado: $event');
      }
    }
  }

  void _clearAllListeners() {
    if (_socket != null) {
      _socket?.off(SocketEvents.loadReservasHorario);
      _socket?.off(SocketEvents.reservasProximas);
      _socket?.off(SocketEvents.newReservaHorario);
      _socket?.off(SocketEvents.newReservaProxima);
    }
  }

  void _clearListeners(events, {List<String>? reservaIds}) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case ReservasEvent.reservasHorario:
          _socket?.off(SocketEvents.loadReservasHorario);
          break;
        case ReservasEvent.reservasProximas:
          _socket?.off(SocketEvents.reservasProximas);
          break;
        case ReservasEvent.newReservaHorario:
          _socket?.off(SocketEvents.newReservaHorario);
          break;
        case ReservasEvent.newReservaProxima:
          _socket?.off(SocketEvents.newReservaProxima);
          break;
        case ReservasEvent.specificReserva:
          if (reservaIds == null) return;
          for (var id in reservaIds) {
            _socket?.off('${SocketEvents.specificReserva}$id');
          }
          break;
      }
    }
  }

  void connect(List<ReservasEvent> events, {List<String>? reservaIds}) {
    _clearListeners(events, reservaIds: reservaIds);
    _registerListeners(events, reservaIds: reservaIds);
  }

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
    _socket!.emit(SocketEvents.reservasProximas, {
      'userId': _userProvider.user?.id ?? 'no id',
      'today': WeekCalculator.formatDate(DateTime.now()),
    });
    _timers[ReservasEvent.reservasProximas] =
        Timer(const Duration(seconds: 10), () {
      if (loadingReservasProximas) {
        loadingReservasProximas = false;
        connectionTimeouts[ReservasEvent.reservasProximas] = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      }
    });

    _socket!.on(SocketEvents.loadReservasProximas, (data) {
      _timers[ReservasEvent.reservasProximas]?.cancel();
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
    _socket!.emit(SocketEvents.reservasHorario, {
      'inicio': WeekCalculator.getWeekDates().inicio,
      'fin': WeekCalculator.getWeekDates().fin,
    });
    _timers[ReservasEvent.reservasHorario] =
        Timer(const Duration(seconds: 10), () {
      if (loadingReservasHorario) {
        loadingReservasHorario = false;
        connectionTimeouts[ReservasEvent.reservasHorario] = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
        print('Error: El servidor no respondió a tiempo');
      }
    });
    _socket!.on(SocketEvents.loadReservasHorario, (data) {
      _timers[ReservasEvent.reservasHorario]?.cancel();
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
      _socket!.on('${SocketEvents.specificReserva}$id', (data) {
        ReservaModel updatedReserva = ReservaModel.fromApi(data);
        int index = reservasHorario.indexWhere((reserva) => reserva.id == id);
        if (index != -1) {
          reservasHorario[index] = ReservaModel.updateFromModel(updatedReserva);
        }

        index = reservasProximas.indexWhere((reserva) => reserva.id == id);
        if (index != -1) {
          reservasProximas[index] =
              ReservaModel.updateFromModel(updatedReserva);
        }
        if (reservaOnDetail != null) {
          reservaOnDetail = updatedReserva;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      });
    }
  }
}
