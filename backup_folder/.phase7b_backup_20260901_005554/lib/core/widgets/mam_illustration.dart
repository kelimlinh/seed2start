import 'package:flutter/material.dart';

enum MamPose {
  hello,
  journey,
  book,
  thinking,
  search,
  happy,
  confused,
  goal,
  reflection,
  celebration,
}

/// Official Mầm artwork registry.
///
/// Pages should request a semantic pose through [MamIllustration] instead of
/// hard-coding asset paths. When a more suitable official artwork is added,
/// only this registry needs to change.
abstract final class MascotAssets {
  static const waving = 'assets/mascot/mam_waving.webp';
  static const questioning = 'assets/mascot/mam_questioning.webp';
  static const like = 'assets/mascot/mam_like.webp';
  static const congratulation = 'assets/mascot/mam_congratulation.webp';
  static const sayHi = 'assets/mascot/mam_say_hi.webp';

  static String? forPose(MamPose pose) {
    return switch (pose) {
      MamPose.hello => waving,
      MamPose.journey => sayHi,
      MamPose.thinking => questioning,
      // The current official set has no magnifying-glass pose yet. The
      // questioning/curious artwork is the closest neutral search state.
      // Replace only this mapping when the dedicated searching artwork exists.
      MamPose.search => questioning,
      MamPose.happy => like,
      MamPose.confused => questioning,
      MamPose.celebration => congratulation,
      MamPose.book || MamPose.goal || MamPose.reflection => null,
    };
  }
}

/// Single integration point for official Mầm artwork.
///
/// This widget never redraws or imitates Mầm with icons/CSS. If a requested
/// official pose has not been supplied yet, it preserves layout space without
/// displaying a fake mascot.
class MamIllustration extends StatelessWidget {
  const MamIllustration({
    super.key,
    required this.pose,
    this.size = 96,
    this.semanticLabel,
  });

  final MamPose pose;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final assetPath = MascotAssets.forPose(pose);

    final child = SizedBox.square(
      dimension: size,
      child: assetPath == null
          ? const SizedBox.shrink()
          : Image.asset(
              assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
    );

    final label = semanticLabel?.trim();
    if (label == null || label.isEmpty) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      image: true,
      label: label,
      child: child,
    );
  }
}
