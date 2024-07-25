class DateTimeUtility {
  static String timeUntilReservation(
      DateTime reservationDate, String reservationTime) {
    // Parse the reservation time string
    final timeParts = reservationTime.split(':');
    final int hours = int.parse(timeParts[0]);
    final int minutes = int.parse(timeParts[1]);

    // Create a DateTime object for the reservation
    final DateTime reservationDateTime = DateTime(
      reservationDate.year,
      reservationDate.month,
      reservationDate.day,
      hours,
      minutes,
    );

    // Get the current DateTime
    final DateTime now = DateTime.now();

    // Calculate the difference
    final Duration difference = reservationDateTime.difference(now);

    // Check the difference and return appropriate string
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'OK';
    }
  }
}
