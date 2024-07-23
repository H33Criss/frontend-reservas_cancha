class HourDifinition {
  String horaInicio;
  String horaFin;

  HourDifinition({
    required this.horaInicio,
    required this.horaFin,
  });
}

List<HourDifinition> hoursDefinitions = [
  HourDifinition(horaInicio: '17:00', horaFin: '18:00'),
  HourDifinition(horaInicio: '18:00', horaFin: '19:00'),
  HourDifinition(horaInicio: '19:00', horaFin: '20:00'),
  HourDifinition(horaInicio: '20:00', horaFin: '21:00'),
  HourDifinition(horaInicio: '21:00', horaFin: '22:00'),
  HourDifinition(horaInicio: '22:00', horaFin: '23:00'),
];

List<String> monthNames = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre'
];

List<String> weekDayNames = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];
