import 'package:pobla_app/infrastructure/models/reserva.model.dart';

class ReservaHelper {
  static List<ReservaModel> ordenarReservas(List<ReservaModel> reservas) {
    reservas.sort((a, b) {
      // Primero ordenar por fechaReserva
      int compareFecha = a.fechaReserva.compareTo(b.fechaReserva);
      if (compareFecha != 0) return compareFecha;

      // Si las fechas son iguales, ordenar por horaInicio
      final timePartsA = a.horaInicio.split(':');
      final int hoursA = int.parse(timePartsA[0]);
      final int minutesA = int.parse(timePartsA[1]);
      final DateTime timeA = DateTime(a.fechaReserva.year, a.fechaReserva.month,
          a.fechaReserva.day, hoursA, minutesA);

      final timePartsB = b.horaInicio.split(':');
      final int hoursB = int.parse(timePartsB[0]);
      final int minutesB = int.parse(timePartsB[1]);
      final DateTime timeB = DateTime(b.fechaReserva.year, b.fechaReserva.month,
          b.fechaReserva.day, hoursB, minutesB);

      return timeA.compareTo(timeB);
    });
    return reservas;
  }
}
