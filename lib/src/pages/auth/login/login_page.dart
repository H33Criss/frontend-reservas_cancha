import 'package:flutter/material.dart';
import 'package:pobla_app/src/pages/auth/login/widgets/button_google_login.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;
    final theme = ShadTheme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height * 0.3,
            decoration: const BoxDecoration(
              color: Colors.red,
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
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              child: ListView(
                children: [
                  Text(
                    'Iniciar sesión',
                    style: textStyles.headlineLarge,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: const ShadInput(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      placeholder: Text('Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  ShadInput(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    placeholder: const Text('Password'),
                    obscureText: true,
                    prefix: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: ShadImage.square(size: 16, LucideIcons.lock),
                    ),
                    suffix: ShadButton(
                      width: 24,
                      height: 24,
                      padding: EdgeInsets.zero,
                      decoration: const ShadDecoration(
                        secondaryBorder: ShadBorder.none,
                        secondaryFocusedBorder: ShadBorder.none,
                      ),
                      icon: ShadImage.square(
                        size: 16,
                        true ? LucideIcons.eyeOff : LucideIcons.eye,
                      ),
                      onPressed: () {
                        //  setState(() => obscure = !obscure);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Stack(
                      children: [
                        ShadButton(
                          width: double.infinity,
                          shadows: [
                            BoxShadow(
                              color: theme.colorScheme.muted.withOpacity(.4),
                              spreadRadius: 4,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            end: Alignment.topLeft,
                            colors: [
                              theme.colorScheme.muted.withBlue(300),
                              theme.colorScheme.muted,
                            ],
                          ),
                          size: ShadButtonSize.lg,
                          backgroundColor: theme.colorScheme.muted,
                          text: const Text(
                            'INICIAR',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        TouchRippleEffect(
                          // width: double.infinity,

                          borderRadius: BorderRadius.circular(5),
                          rippleColor: Colors.white60,
                          onTap: () {
                            print("adi !");
                          },
                          child: SizedBox(
                            width: double.infinity,
                            height: size.height * 0.07,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
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
    );
  }
}
