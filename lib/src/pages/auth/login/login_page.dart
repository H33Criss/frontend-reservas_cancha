import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:pobla_app/src/helpers/forms/validators_form.dart';
import 'package:pobla_app/src/pages/auth/login/widgets/button_google_login.dart';
import 'package:pobla_app/src/pages/auth/login/widgets/button_normal_login.dart';
import 'package:pobla_app/src/pages/auth/login/widgets/shad_input_password.dart';
import 'package:pobla_app/src/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();
  final formKey = GlobalKey<ShadFormState>();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;
    final theme = ShadTheme.of(context);
    //Don't delete that, this instance triggers ..renewUser().
    final userProvider = context.watch<UserProvider>();
    //Don't delete that, this instance triggers ..initSocket().
    final bloqueoProvider = context.watch<BloqueosProvider>();
    //Don't delete that, this instance triggers ..initialize().
    final reservaProvider = context.watch<ReservaProvider>();
    return Scaffold(
      body: userProvider.renewingUser
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : FadeIn(
              child: ShadForm(
                key: formKey,
                child: Stack(
                  children: [
                    Container(
                      height: size.height * 0.3,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/pelota.jpg'),
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: size.height * 0.28),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: theme.colorScheme.background,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 30),
                        child: ListView(
                          children: [
                            Text(
                              'Iniciar sesión',
                              style: textStyles.headlineLarge,
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                              child: ShadInputFormField(
                                  id: 'email',
                                  style: textStyles.titleMedium,
                                  controller: controllerEmail,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 15),
                                  placeholder: const Text('Email'),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Indique su email';
                                    }
                                    if (ValidatorsForm.isValidEmail(value)) {
                                      return null;
                                    } else {
                                      return 'Ingrese un formato de email valido';
                                    }
                                  }),
                            ),
                            ShadInputPassword(
                                controllerPassword: controllerPassword),
                            ButtonNormalLogin(
                              email: controllerEmail,
                              password: controllerPassword,
                              formKey: formKey,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: Center(
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Center(
                                child: RichText(
                                  text: TextSpan(children: [
                                    const TextSpan(
                                      text: '¿No tienes una cuenta?',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Registrarse',
                                      style: TextStyle(
                                        color: theme.colorScheme.muted,
                                        fontSize: 15,
                                      ),
                                    )
                                  ]),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              alignment: Alignment.center,
                              child: const Text('O'),
                            ),
                            const SizedBox(height: 10),
                            const ButtonGoogleLogin()
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
