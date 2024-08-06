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
  reservasProximas,
  reservasTotales, // de un usuario
  newReservaHorario,
  newReservaProxima,
  newReserva, // de un usuario
  specificReserva,
}

class SocketEvents {
  //Piden una lista de reservas
  static const String reservasHorario = 'reservasHorario';
  static const String reservasProximas = 'reservasProximas';
  static const String reservasTotales = 'reservasTotales';

  //Reciben una lista de reservas
  static const String loadReservasHorario = 'loadReservasHorario';
  static const String loadReservasProximas = 'loadReservasProximas';
  static const String loadReservasTotales = 'loadReservasTotales';

  //Reciben una reserva individual
  static const String newReservaHorario = 'newReservaHorario';
  static const String newReservaProxima = 'newReservaProxima';

  //Reciben cambios en una reserva individual
  static const String newReserva = 'newReserva-'; // +ID de usuario
  static const String specificReserva = 'reserva-'; // +ID de alguna reserva
}

mixin SocketReservaProvider on ChangeNotifier {
  ReservaModel? reservaOnDetail;
  List<ReservaModel> reservasHorario = [];
  List<ReservaModel> reservasProximas = [];
  List<ReservaModel> reservasTotales = [];
  bool loadingReservasHorario = false;
  bool loadingReservasProximas = false;
  bool loadingReservasTotales = false;
  io.Socket? _socket;
  io.Socket? get socket => _socket;

  final Map<ReservasEvent, Timer?> _timers = {};
  final Map<ReservasEvent, bool> connectionTimeouts = {
    ReservasEvent.reservasHorario: false,
    ReservasEvent.reservasProximas: false,
    ReservasEvent.reservasTotales: false,
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
    _socket!.on('update-${_userProvider.user?.id ?? 'no id'}-reserva', (data) {
      ReservaModel updatedReserva = ReservaModel.fromApi(data);
      _updateIfReservaExists(updatedReserva);
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
    _socket?.connect();
  }

  void connect(List<ReservasEvent> events, {List<String>? reservaIds}) {
    _clearListeners(events, reservaIds: reservaIds);
    _registerListeners(events, reservaIds: reservaIds);
  }

  void disconnect(List<ReservasEvent> events, {List<String>? reservaIds}) {
    _clearListeners(events, reservaIds: reservaIds);
  }

  void _disposeSocket() {
    //Esta funcion debería ejecutarse en cada cierre de sesión
    _clearAllListeners();
    _socket?.disconnect();
    _socket = null;
    reservasProximas.clear();
    reservasHorario.clear();
  }

  void _registerListeners(List<ReservasEvent> events,
      {List<String>? reservaIds}) {
    if (_socket == null) return;
    for (var event in events) {
      switch (event) {
        case ReservasEvent.reservasHorario:
          _handleReservasEvent(
            emitEvent: SocketEvents.reservasHorario,
            loadEvent: SocketEvents.loadReservasHorario,
            reservasList: reservasHorario,
            setLoading: (loading) => loadingReservasHorario = loading,
            timeoutKey: ReservasEvent.reservasHorario,
            emitPayload: {
              'inicio': WeekCalculator.getWeekDates().inicio,
              'fin': WeekCalculator.getWeekDates().fin,
            },
          );
          break;

        case ReservasEvent.reservasProximas:
          _handleReservasEvent(
            emitEvent: SocketEvents.reservasProximas,
            loadEvent: SocketEvents.loadReservasProximas,
            reservasList: reservasProximas,
            setLoading: (loading) => loadingReservasProximas = loading,
            timeoutKey: ReservasEvent.reservasProximas,
            emitPayload: {
              'userId': _userProvider.user?.id ?? 'no id',
              'today': WeekCalculator.formatDate(DateTime.now()),
            },
          );
          break;

        case ReservasEvent.reservasTotales:
          _handleReservasEvent(
            emitEvent: SocketEvents.reservasTotales,
            loadEvent: SocketEvents.loadReservasTotales,
            reservasList: reservasTotales,
            setLoading: (loading) => loadingReservasTotales = loading,
            timeoutKey: ReservasEvent.reservasTotales,
            emitPayload: {
              'userId': _userProvider.user?.id ?? 'no id',
            },
          );
          break;

        case ReservasEvent.newReservaHorario:
          _handleNewReservaEvent(
            newEvent: SocketEvents.newReservaHorario,
            reservasList: reservasHorario,
          );
          break;

        case ReservasEvent.newReservaProxima:
          _handleNewReservaEvent(
            newEvent: SocketEvents.newReservaProxima,
            reservasList: reservasProximas,
          );
          break;

        case ReservasEvent.newReserva:
          _handleNewReservaEvent(
            newEvent:
                '${SocketEvents.newReserva}${_userProvider.user?.id ?? 'no id'}',
            reservasList: reservasTotales,
          );
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
      _socket?.off(SocketEvents.loadReservasProximas);
      _socket?.off(SocketEvents.loadReservasTotales);
      _socket?.off(SocketEvents.newReservaHorario);
      _socket?.off(SocketEvents.newReservaProxima);
      _socket?.off('${SocketEvents.newReserva}${_userProvider.user?.id}');
      _socket?.off('update-${_userProvider.user?.id ?? 'no id'}-reserva');
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
        case ReservasEvent.reservasTotales:
          _socket?.off(SocketEvents.reservasTotales);
          break;
        case ReservasEvent.newReservaHorario:
          _socket?.off(SocketEvents.newReservaHorario);
          break;
        case ReservasEvent.newReservaProxima:
          _socket?.off(SocketEvents.newReservaProxima);
          break;
        case ReservasEvent.newReserva:
          _socket?.off('${SocketEvents.newReserva}${_userProvider.user?.id}');
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

  void _handleReservasEvent({
    required String emitEvent,
    required String loadEvent,
    required List<ReservaModel> reservasList,
    required void Function(bool) setLoading,
    required ReservasEvent timeoutKey,
    required Map<String, dynamic> emitPayload,
  }) {
    setLoading(true);
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    _socket!.emit(emitEvent, emitPayload);
    _timers[timeoutKey] = Timer(const Duration(seconds: 10), () {
      setLoading(false);
      connectionTimeouts[timeoutKey] = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });

    _socket!.on(loadEvent, (data) {
      _timers[timeoutKey]?.cancel();
      List<Map<String, dynamic>> reservasData =
          List<Map<String, dynamic>>.from(data);
      reservasList.clear();
      reservasList
          .addAll(reservasData.map((r) => ReservaModel.fromApi(r)).toList());
      setLoading(false);
      connectionTimeouts[timeoutKey] = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
  }

  void _handleNewReservaEvent({
    required String newEvent,
    required List<ReservaModel> reservasList,
  }) {
    _socket!.on(newEvent, (data) {
      ReservaModel newReserva = ReservaModel.fromApi(data);
      reservasList.add(newReserva);
      reservasList = ReservaHelper.ordenarReservas(reservasList);
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    });
  }

  void _updateIfReservaExists(ReservaModel updatedReserva) {
    void updateReservaInList(List<ReservaModel> reservas) {
      int index =
          reservas.indexWhere((reserva) => reserva.id == updatedReserva.id);
      if (index != -1) {
        reservas[index] = ReservaModel.updateFromModel(updatedReserva);
      }
    }

    updateReservaInList(reservasHorario);
    updateReservaInList(reservasProximas);
    updateReservaInList(reservasTotales);
  }
}
