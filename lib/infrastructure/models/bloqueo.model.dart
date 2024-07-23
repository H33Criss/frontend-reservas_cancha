class BloqueoModel {
  String id;
  String tipo;
  DateTime? dia;
  DateTime? semanaInicio;
  DateTime? semanaFin;
  String? horaInicio;
  String? horaFin;

  BloqueoModel({
    required this.id,
    required this.tipo,
    this.dia,
    this.semanaInicio,
    this.semanaFin,
    this.horaInicio,
    this.horaFin,
  });

  factory BloqueoModel.fromApi(Map<String, dynamic> bloqueo) {
    DateTime? dia =
        bloqueo['dia'] == null ? null : DateTime.parse(bloqueo['dia']);
    DateTime? semanaInicio = bloqueo['semanaInicio'] == null
        ? null
        : DateTime.parse(bloqueo['semanaInicio']);
    DateTime? semanaFin = bloqueo['semanaFin'] == null
        ? null
        : DateTime.parse(bloqueo['semanaFin']);

    return BloqueoModel(
      id: bloqueo['id'],
      tipo: bloqueo['tipo'],
      dia: dia,
      semanaInicio: semanaInicio,
      semanaFin: semanaFin,
      horaInicio: bloqueo['horaInicio'],
      horaFin: bloqueo['horaFin'],
    );
  }
}
