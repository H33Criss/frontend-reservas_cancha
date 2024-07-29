class ReservaModel {
  String id;
  String diaSemana;
  String horaInicio;
  String horaFin;
  DateTime fechaReserva;
  // String estado; //confirmada,pendiente, cancelada
  bool pagada;
  int coste;
  String userId;

  ReservaModel({
    required this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.fechaReserva,
    required this.pagada,
    required this.coste,
    required this.userId,
  });

  factory ReservaModel.fromApi(Map<String, dynamic> reserva) {
    DateTime fechaReserva = DateTime.parse(reserva['fechaReserva']);

    return ReservaModel(
      id: reserva['id'],
      diaSemana: reserva['diaSemana'],
      horaInicio: reserva['horaInicio'],
      horaFin: reserva['horaFin'] ?? 'Sin tipo',
      fechaReserva: fechaReserva,
      pagada: reserva['pagada'],
      coste: reserva['coste'],
      userId: reserva['user'],
    );
  }
  factory ReservaModel.returnSentinel() {
    return ReservaModel(
      id: '',
      diaSemana: '',
      horaInicio: '',
      horaFin: '',
      fechaReserva: DateTime.now(),
      pagada: false,
      coste: 0,
      userId: '',
    );
  }
  factory ReservaModel.updateFromModel(ReservaModel reserva) {
    return ReservaModel(
      id: reserva.id,
      diaSemana: reserva.diaSemana,
      horaInicio: reserva.horaInicio,
      horaFin: reserva.horaFin,
      fechaReserva: reserva.fechaReserva,
      pagada: reserva.pagada,
      coste: reserva.coste,
      userId: reserva.userId,
    );
  }
}
