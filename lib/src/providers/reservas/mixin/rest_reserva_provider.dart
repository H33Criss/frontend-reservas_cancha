import 'package:flutter/material.dart';
import 'package:pobla_app/config/environment/environment.dart';
import 'package:dio/dio.dart';

mixin RestReservaProvider on ChangeNotifier {
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiRestUrl,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImFjNzUzMjk2LTZkYjUtNDg0Zi04NzAyLTA3NTA0MTQ5Mzg2MyIsImlhdCI6MTcyMTUxMzcyNSwiZXhwIjoxNzIxNTIwOTI1fQ.0QV65trlvWhno2UdqSHnmEMP8CNhWdU3FSgWQXsJCN4',
      },
    ),
  );
  bool creatingReserva = false;

  Future<void> editReservas() async {}
  Future<void> cancelReserva(String idReserva) async {}

  Future<void> addReserva(Map<String, dynamic> reservaData) async {
    creatingReserva = true;
    notifyListeners();
    print(reservaData);
    await dio.post('/reservas', data: reservaData).then((response) {
      creatingReserva = false;
      notifyListeners();
    }).catchError((error) {
      if (error is DioException) {
        print(error.message);
        // Puedes acceder a más propiedades de DioError, como response y type
        print(error.response?.data);
        print(error.type);
      } else {
        // Manejar otros tipos de errores si es necesario
        print('Error desconocido: $error');
      }
      creatingReserva = false;
      notifyListeners();
    });
  }
}
