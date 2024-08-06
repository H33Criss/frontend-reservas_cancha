import 'package:pobla_app/infrastructure/models/reserva.model.dart';

enum ReservaStatus {
  faltaTiempo,
  enCurso,
  tiempoAcabado,
}

class ReservaTimeHelper {
  static ReservaStatus getReservaStatus(
      DateTime date, String horaInicio, String horaFin) {
    DateTime now = DateTime.now();

    // Parsear la hora de inicio y fin del string
    List<String> partsInicio = horaInicio.split(':');
    int hoursInicio = int.parse(partsInicio[0]);
    int minutesInicio = int.parse(partsInicio[1]);
    DateTime dateTimeInicio =
        DateTime(date.year, date.month, date.day, hoursInicio, minutesInicio);

    List<String> partsFin = horaFin.split(':');
    int hoursFin = int.parse(partsFin[0]);
    int minutesFin = int.parse(partsFin[1]);
    DateTime dateTimeFin =
        DateTime(date.year, date.month, date.day, hoursFin, minutesFin);

    if (now.isBefore(dateTimeInicio)) {
      return ReservaStatus.faltaTiempo;
    } else if (now.isAfter(dateTimeFin)) {
      return ReservaStatus.tiempoAcabado;
    } else {
      return ReservaStatus.enCurso;
    }
  }

  static String getReservaRelativeTime(
      DateTime date, String horaInicio, String horaFin) {
    DateTime now = DateTime.now();

    // Solo considerar la parte de la fecha
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime reservaDate = DateTime(date.year, date.month, date.day);

    if (today.isAtSameMomentAs(reservaDate)) {
      // Parsear la hora de inicio y fin del string
      List<String> partsInicio = horaInicio.split(':');
      int hoursInicio = int.parse(partsInicio[0]);
      int minutesInicio = int.parse(partsInicio[1]);
      DateTime dateTimeInicio =
          DateTime(date.year, date.month, date.day, hoursInicio, minutesInicio);

      List<String> partsFin = horaFin.split(':');
      int hoursFin = int.parse(partsFin[0]);
      int minutesFin = int.parse(partsFin[1]);
      DateTime dateTimeFin =
          DateTime(date.year, date.month, date.day, hoursFin, minutesFin);

      if (now.isAfter(dateTimeInicio) && now.isBefore(dateTimeFin)) {
        return 'Ahora';
      }
      return 'Hoy';
    } else if (reservaDate
        .isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Mañana';
    } else {
      int differenceInDays = reservaDate.difference(today).inDays;
      return 'En $differenceInDays días';
    }
  }

  static String addFiveMinutes(String time) {
    // Parsear la hora del string
    List<String> parts = time.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    // Crear un objeto DateTime con la hora dada
    DateTime dateTime = DateTime(0, 1, 1, hours, minutes);

    // Sumar 5 minutos
    dateTime = dateTime.add(const Duration(minutes: 5));

    // Formatear de vuelta a string
    String formattedTime = _formatTime(dateTime);
    return formattedTime;
  }

  static List<ReservaModel> filtrarReservasViejas(
      List<ReservaModel> reservasProximas, List<ReservaModel> reservasTotales) {
    // Filtrar las reservas viejas
    List<ReservaModel> reservasViejas = reservasTotales.where((reservaTotal) {
      return !reservasProximas.any((reservaProxima) =>
          reservaTotal.fechaReserva
              .isAtSameMomentAs(reservaProxima.fechaReserva) &&
          reservaTotal.horaInicio == reservaProxima.horaInicio &&
          reservaTotal.horaFin == reservaProxima.horaFin);
    }).toList();

    return reservasViejas;
  }

  static String subtractFiveMinutes(String time) {
    // Parsear la hora del string
    List<String> parts = time.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    // Crear un objeto DateTime con la hora dada
    DateTime dateTime = DateTime(0, 1, 1, hours, minutes);

    // Restar 5 minutos
    dateTime = dateTime.subtract(const Duration(minutes: 5));

    // Formatear de vuelta a string
    String formattedTime = _formatTime(dateTime);
    return formattedTime;
  }

  static String timeUntil(DateTime date, String horaInicio, {String? horaFin}) {
    // Parsear la hora de inicio del string
    List<String> partsInicio = horaInicio.split(':');
    int hoursInicio = int.parse(partsInicio[0]);
    int minutesInicio = int.parse(partsInicio[1]);

    // Crear un objeto DateTime con la fecha y hora de inicio dadas
    DateTime dateTimeInicio =
        DateTime(date.year, date.month, date.day, hoursInicio, minutesInicio);

    // Calcular la diferencia de tiempo
    DateTime now = DateTime.now();
    Duration differenceInicio = dateTimeInicio.difference(now);

    // Si horaFin está presente, procesarla
    if (horaFin != null) {
      List<String> partsFin = horaFin.split(':');
      int hoursFin = int.parse(partsFin[0]);
      int minutesFin = int.parse(partsFin[1]);

      DateTime dateTimeFin =
          DateTime(date.year, date.month, date.day, hoursFin, minutesFin);

      if (now.isAfter(dateTimeInicio) && now.isBefore(dateTimeFin)) {
        return 'En curso';
      } else if (now.isAfter(dateTimeFin)) {
        return 'Tiempo acabado';
      }
    }

    if (differenceInicio.isNegative) {
      // La fecha ya pasó
      return 'Tiempo acabado';
    }

    // Calcular horas, minutos, segundos y milisegundos restantes
    int totalMinutes = differenceInicio.inMinutes;
    int hoursRemaining = totalMinutes ~/ 60;
    int minutesRemaining = totalMinutes % 60;

    // Considerar segundos y milisegundos para precisión en minutos
    if (differenceInicio.inSeconds % 60 > 0 ||
        differenceInicio.inMilliseconds % 1000 > 0) {
      minutesRemaining += 1;
      if (minutesRemaining == 60) {
        minutesRemaining = 0;
        hoursRemaining += 1;
      }
    }

    // Formatear la diferencia de tiempo
    if (differenceInicio.inDays > 0) {
      int days = differenceInicio.inDays;
      int hours = hoursRemaining % 24;
      return '$days ${days == 1 ? "día" : "días"} y $hours ${hours == 1 ? "hora" : "horas"}';
    } else {
      int hours = hoursRemaining;
      int minutes = minutesRemaining;
      return '$hours ${hours == 1 ? "hora" : "horas"} y $minutes ${minutes == 1 ? "minuto" : "minutos"}';
    }
  }

  static bool isTimeRemaining(DateTime date, String time) {
    // Parsear la hora del string
    List<String> parts = time.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    // Crear un objeto DateTime con la fecha y hora dadas
    DateTime dateTime =
        DateTime(date.year, date.month, date.day, hours, minutes);

    // Calcular la diferencia de tiempo
    Duration difference = dateTime.difference(DateTime.now());

    // Devolver true si aún queda tiempo, false si la fecha y hora actuales son mayores
    return !difference.isNegative;
  }

  // Método privado para formatear la hora en string
  static String _formatTime(DateTime dateTime) {
    String hours = dateTime.hour.toString().padLeft(2, '0');
    String minutes = dateTime.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
