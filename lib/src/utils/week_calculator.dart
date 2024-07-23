class WeekResponse {
  DateTime today;
  DateTime firstDayOfWeek;
  DateTime lastDayOfWeek;
  String inicio;
  String fin;

  WeekResponse({
    required this.today,
    required this.firstDayOfWeek,
    required this.lastDayOfWeek,
    required this.inicio,
    required this.fin,
  });
}

class WeekCalculator {
  static WeekResponse getWeekDates() {
    DateTime date = DateTime.now();
    DateTime firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    //Lunes + 6 dias =  Domingo
    DateTime lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

    DateTime normalizedMinDate =
        DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day);
    DateTime normalizedMaxDate =
        DateTime(lastDayOfWeek.year, lastDayOfWeek.month, lastDayOfWeek.day);

    return WeekResponse(
      today: date,
      firstDayOfWeek: normalizedMinDate,
      lastDayOfWeek: normalizedMaxDate.add(
        const Duration(hours: 23, minutes: 59, seconds: 59),
      ),
      inicio: formatDate(normalizedMinDate),
      fin: formatDate(normalizedMaxDate),
    );
  }

  static String formatDate(DateTime date) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String year = date.year.toString();
    String month = twoDigits(date.month);
    String day = twoDigits(date.day);
    return '$year-$month-$day';
  }
}
