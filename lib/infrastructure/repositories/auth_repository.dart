import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pobla_app/config/environment/environment.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

class AuthRepository {
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiRestUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<dynamic> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('response: $response');
        print('Failed to authenticate with backend');
        throw Exception('Invalid credentials');
      }
    } catch (error) {
      if (error is DioException) {
        print('DioError: $error');
        print('DioException: ${error.response?.data}');
        if (error.type == DioExceptionType.connectionTimeout) {
          throw Exception('Servidor bajo mantenimiento.');
        }
        throw Exception(error.response?.data['message'] ?? 'Unknown error');
      } else {
        print('Error desconocido: $error');
        throw Exception('App Unknown error');
      }
    }
  }

  Future<dynamic> loginWithGoogle() async {
    await _googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return null; // El usuario canceló el inicio de sesión
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    try {
      final response = await dio.post(
        '/auth/google/validate',
        data: {'idToken': googleAuth.idToken},
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('response: $response');
        print('Failed to authenticate with backend');
      }
    } catch (error) {
      if (error is DioException) {
        print('DioError: $error');
        print('DioException: ${error.response?.data}');
        if (error.type == DioExceptionType.connectionTimeout) {
          throw Exception('Servidor bajo mantenimiento.');
        }
        throw Exception(error.response?.data['message'] ?? 'Unknown error');
      } else {
        print('Error desconocido: $error');
        throw Exception('App Unknown error');
      }
    }
  }

  Future<dynamic> renewToken(String idToken) async {
    try {
      final response =
          await dio.post('/auth/token/renew', data: {'idToken': idToken});
      if (response.statusCode == 200) {
        return response.data;
      } else {
        // Handle errors
        print('Failed to renew token');
        return null;
      }
    } catch (error) {
      if (error is DioException) {
        // Handle Dio errors
        print(error.response?.data);
      } else {
        // Handle other errors
        print('Unknown error: $error');
      }
      return null;
    }
  }

  Future<void> signOutUser() async {
    await GoogleSignIn().signOut();
  }
}
