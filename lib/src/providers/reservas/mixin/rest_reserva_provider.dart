import 'package:flutter/material.dart';
import 'package:pobla_app/config/environment/environment.dart';
import 'package:dio/dio.dart';
import 'package:pobla_app/src/providers/user/user_provider.dart';

//mixin, porque se separo la logica de socket y rest en 2 archivos
//para conformar 1 provider, llamado "ReservaProvider"
mixin RestReservaProvider on ChangeNotifier {
  late Dio dio;
  late UserProvider _userProvider;

  bool creatingReserva = false;

  void initialize(UserProvider userProvider) {
    _userProvider = userProvider;
    _updateDio();
    //Para que cada vez que el usuario cambie, se inicialize un nuevo dio, con otro token
    //en el header.
    _userProvider.userListener.addListener(_updateDio);
  }

  void _updateDio() {
    //Nuevo dio con otro token de usuario.
    dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiRestUrl,
        headers: {
          'Authorization':
              'Bearer ${_userProvider.userListener.value?.jwtToken}',
        },
      ),
    );
  }

  Future<void> editReservas() async {}
  Future<void> cancelReserva(String idReserva) async {}

  Future<void> addReserva(Map<String, dynamic> reservaData) async {
    creatingReserva = true;
    notifyListeners();
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

  @override
  void dispose() {
    _userProvider.userListener.removeListener(_updateDio);
    super.dispose();
  }
}
