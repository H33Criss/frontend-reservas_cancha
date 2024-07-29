import 'package:intl/intl.dart';

class StepHelper {
  static int calculateCurrentStep(
      String horaInicio, String horaFin, DateTime fechaReserva) {
    DateTime now = DateTime.now();
    DateTime startTime = _parseTime(horaInicio, fechaReserva);
    DateTime endTime = _parseTime(horaFin, fechaReserva);
    DateTime endTimePlusFive = endTime.add(const Duration(minutes: 5));
    if (now.isBefore(startTime.subtract(const Duration(minutes: 5)))) {
      return 0;
    } else if (now.isAfter(startTime) && now.isBefore(endTime)) {
      return 1;
    } else if (now.isAfter(endTime) && now.isBefore(endTimePlusFive)) {
      return 2;
    } else if (now.isAfter(endTimePlusFive)) {
      return 3;
    } else {
      return 0;
    }
  }

  static DateTime _parseTime(String time, DateTime referenceDate) {
    final format = DateFormat.Hm(); // HH:mm
    DateTime parsedTime = format.parse(time);
    return DateTime(referenceDate.year, referenceDate.month, referenceDate.day,
        parsedTime.hour, parsedTime.minute);
  }
}
