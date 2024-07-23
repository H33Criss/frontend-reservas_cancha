import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pobla_app/config/environment/environment.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
    // scopes: ['email', 'profile'],
    // clientId: Environment.googleCliendId,
    );

class AuthRepository {
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiRestUrl,
    ),
  );

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
        print(error.response?.data);
      } else {
        print('Error desconocido: $error');
      }

      return null;
    }
  }
}
