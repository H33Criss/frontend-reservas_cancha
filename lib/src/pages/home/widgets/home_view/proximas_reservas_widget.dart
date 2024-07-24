import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

List<int> elements = [1, 2, 3, 4, 5, 6, 7];

class ProximasReservasWidget extends StatelessWidget {
  const ProximasReservasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final textStyles = ShadTheme.of(context).textTheme;
    final colors = ShadTheme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: size.height * 0.28,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: elements.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.blue[900],
              borderRadius: BorderRadius.circular(30),
            ),
            width: size.width * 0.45,
            height: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: -size.height * 0.06,
                    child: Container(
                      width: size.height * 0.18,
                      height: size.height * 0.18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.06),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: size.width * 0.16,
                    child: Container(
                      width: size.height * 0.02,
                      height: size.height * 0.02,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: size.width * 0.03,
                    child: Container(
                      width: size.height * 0.06,
                      height: size.height * 0.06,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.06),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(MdiIcons.soccer),
                              ),
                              const SizedBox(width: 5),
                              Text('Reserva', style: textStyles.h4),
                            ],
                          ),
                          SizedBox(height: size.height * 0.02),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: '18:00',
                                style: textStyles.h4,
                              ),
                              TextSpan(
                                text: ' - ',
                                style: textStyles.h4,
                              ),
                              TextSpan(
                                text: '19:00',
                                style: textStyles.h4,
                              ),
                            ]),
                          ),
                          const Spacer(),
                          RippleAnimation(
                              color: colors.muted.withOpacity(.5),
                              delay: const Duration(milliseconds: 300),
                              repeat: true,
                              minRadius: 30,
                              ripplesCount: 1,
                              duration: const Duration(milliseconds: 6 * 300),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.muted.withOpacity(.5),
                                ),
                                width: size.height * 0.1,
                                height: size.height * 0.1,
                                child: Column(
                                  // mainAxisAlignment:
                                  //     MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: size.height * 0.03,
                                    ),
                                    Text(
                                      'Faltan',
                                      style: textStyles.small,
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      '3 dias',
                                      style: textStyles.small,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )),
                          const Spacer(),
                          Text(
                            'Jueves 25 de Julio',
                            style: textStyles.small
                                .copyWith(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
