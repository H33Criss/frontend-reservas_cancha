class ReservaTimeHelper {
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

  // Método privado para formatear la hora en string
  static String _formatTime(DateTime dateTime) {
    String hours = dateTime.hour.toString().padLeft(2, '0');
    String minutes = dateTime.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
