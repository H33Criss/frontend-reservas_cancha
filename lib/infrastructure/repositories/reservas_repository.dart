import 'package:dio/dio.dart';
import 'package:pobla_app/config/environment/environment.dart';
import 'package:pobla_app/infrastructure/models/reserva.model.dart';
import 'package:pobla_app/src/providers/user/user_provider.dart';

class ReservasRepository {
  late Dio dio;

  ReservasRepository(UserProvider userProvider) {
    // Escucha cambios en el usuario y actualiza el Dio en consecuencia
    userProvider.userListener.addListener(() => _updateDio(userProvider));
  }

  void _updateDio(UserProvider userProvider) {
    dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiRestUrl,
        headers: {
          'Authorization':
              'Bearer ${userProvider.userListener.value?.jwtToken}',
        },
      ),
    );
  }

  Future<void> addReserva(Map<String, dynamic> reservaData) async {
    try {
      await dio.post('/reservas', data: reservaData);
    } on DioException catch (error) {
      print(error.message);
      print(error.response?.data);
      print(error.type);
      throw Exception(error.response?.data['message'] ?? 'Unknown error');
    } catch (error) {
      print('Error desconocido: $error');
      throw Exception('Unknown error');
    }
  }

  Future<ReservaModel?> getReservaById(String id) async {
    try {
      final response = await dio.get('/reservas/$id');
      final reserva =
          ReservaModel.fromApi(response.data.cast<String, dynamic>());
      return reserva;
    } on DioException catch (error) {
      print(error.message);
      print(error.response?.data);
      print(error.type);
      throw Exception(error.response?.data['message'] ?? 'Unknown error');
    } catch (error) {
      print('Error desconocido: $error');
      throw Exception('Unknown error');
    }
  }

  Future<void> editReservas() async {
    // Implementación para editar reservas
  }

  Future<void> cancelReserva(String idReserva) async {
    // Implementación para cancelar reservas
  }
}
