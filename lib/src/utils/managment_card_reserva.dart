import 'package:pobla_app/infrastructure/models/bloqueo.model.dart';
import 'package:pobla_app/infrastructure/models/reserva.model.dart';
import 'package:pobla_app/src/data/hours_definitions.dart';

class ManagementCardReserva {
  static bool isBlocked(
      DateTime selectedDate, HourDifinition hour, List<BloqueoModel> bloqueos) {
    List<BloqueoModel> bloqueosSemana =
        bloqueos.where((bloqueo) => bloqueo.tipo == 'semana').toList();
    for (var bloqueo in bloqueosSemana) {
      if (selectedDate.isAfter(bloqueo.semanaInicio!) &&
          selectedDate.isBefore(bloqueo.semanaFin!.add(
            const Duration(hours: 23, minutes: 59, seconds: 59),
          ))) {
        return true;
      }
    }

    List<BloqueoModel> bloqueosDia =
        bloqueos.where((bloqueo) => bloqueo.tipo == 'dia').toList();
    for (var bloqueo in bloqueosDia) {
      if (_isSameDay(selectedDate, bloqueo.dia!)) {
        return true;
      }
    }

    List<BloqueoModel> bloqueosHora =
        bloqueos.where((bloqueo) => bloqueo.tipo == 'hora').toList();
    for (var bloqueo in bloqueosHora) {
      if (bloqueo.horaInicio == hour.horaInicio &&
          bloqueo.horaFin == hour.horaFin &&
          _isSameDay(selectedDate, bloqueo.dia!)) {
        return true;
      }
    }

    return false;
  }

  static bool isOwnReservation(DateTime selectedDate, HourDifinition hour,
      List<ReservaModel> reservas, String userId) {
    for (var reserva in reservas) {
      if (_isSameDay(selectedDate, reserva.fechaReserva) &&
          reserva.horaInicio == hour.horaInicio &&
          reserva.horaFin == hour.horaFin &&
          reserva.userId == userId) {
        return true;
      }
    }
    return false;
  }

  static bool isOwnReservationPast(DateTime selectedDate, HourDifinition hour,
      List<ReservaModel> reservas, String userId) {
    final now = DateTime.now();

    for (var reserva in reservas) {
      if (_isSameDay(selectedDate, reserva.fechaReserva) &&
          reserva.horaInicio == hour.horaInicio &&
          reserva.horaFin == hour.horaFin &&
          reserva.userId == userId &&
          selectedDate.isBefore(DateTime(now.year, now.month, now.day))) {
        return true;
      }
    }
    return false;
  }

  static bool isTaken(
      DateTime selectedDate, HourDifinition hour, List<ReservaModel> reservas) {
    for (var reserva in reservas) {
      if (_isSameDay(selectedDate, reserva.fechaReserva) &&
          reserva.horaInicio == hour.horaInicio &&
          reserva.horaFin == hour.horaFin) {
        return true;
      }
    }
    return false;
  }

  static bool isPast(DateTime selectedDate) {
    DateTime now = DateTime.now();
    return selectedDate.isBefore(DateTime(now.year, now.month, now.day));
  }

  static bool hasReservationOnDate(
      DateTime selectedDate, List<ReservaModel> reservas, String userId) {
    for (var reserva in reservas) {
      if (_isSameDay(selectedDate, reserva.fechaReserva) &&
          reserva.userId == userId) {
        return true;
      }
    }
    return false;
  }

  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
