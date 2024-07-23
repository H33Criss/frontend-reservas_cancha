import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initEnvironment() async {
    await dotenv.load(fileName: '.env');
  }

  static String apiRestUrl =
      dotenv.env['API_REST_URL'] ?? 'No se ha definido la API_REST_URL';
  static String apiSocketUrl =
      dotenv.env['API_SOCKET_URL'] ?? 'No se ha definido la API_SOCKET_URL';
  static String googleCliendId =
      dotenv.env['GOOGLE_CLIENT_ID'] ?? 'No se ha definido un GOOGLE_CLIENT_ID';
}
