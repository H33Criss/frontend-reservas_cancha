import 'package:flutter/material.dart';
import 'package:flutter_skeleton_ui/flutter_skeleton_ui.dart';

class CardReservaSkeleton extends StatelessWidget {
  const CardReservaSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          padding:
              EdgeInsets.symmetric(horizontal: size.width * 0.01, vertical: 10),
          margin: const EdgeInsets.only(
            bottom: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                      shape: BoxShape.circle,
                      width: size.width * 0.2,
                      height: size.height * 0.04,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                      width: size.width * 0.2,
                      height: size.height * 0.04,
                    ),
                  ),
                  SizedBox(height: size.height * 0.035),
                  SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                      width: size.width * 0.2,
                      height: size.height * 0.04,
                    ),
                  ),
                ],
              ),
              SizedBox(width: size.width * 0.01),
              SkeletonAvatar(
                style: SkeletonAvatarStyle(
                  width: size.width * 0.75,
                  height: size.height * 0.2,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
