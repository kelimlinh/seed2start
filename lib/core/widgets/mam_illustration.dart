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
  media,
  challenge,
  celebration,

  planning,
  confident,
  keepGoing,
  idea,
  problemSolving,
  prototyping,
  creatingValue,
  watering,
  trophy,
  guiding,

  // Optional specialized artwork. If the PNG has not been created yet,
  // MamIllustration automatically falls back to an older official mascot.
  selfDiscovery,
  futureSeed,
  fourResources,
  optimisticView,
  connectingResources,
  creativePaths,
  journeyMap,
  choice,
  realCase,
  smallStep,
}

/// Central registry for all official Mầm artwork.
///
/// Unified convention:
///   assets/mascot/
///
/// New PNGs and the older WebP assets can safely live in the same folder.
abstract final class MascotAssets {
  // New official PNG set.
  static const reading = 'assets/mascot/mam_reading.png';
  static const thinking = 'assets/mascot/mam_thinking.png';
  static const searching = 'assets/mascot/mam_searching.png';
  static const success = 'assets/mascot/mam_success.png';
  static const confused = 'assets/mascot/mam_confused.png';
  static const reflecting = 'assets/mascot/mam_reflecting.png';
  static const planning = 'assets/mascot/mam_planning.png';
  static const confident = 'assets/mascot/mam_confident.png';
  static const keepGoing = 'assets/mascot/mam_keep_going.png';
  static const idea = 'assets/mascot/mam_idea.png';
  static const problemSolving = 'assets/mascot/mam_problem_solving.png';
  static const prototyping = 'assets/mascot/mam_prototyping.png';
  static const creatingValue = 'assets/mascot/mam_creating_value.png';
  static const watering = 'assets/mascot/mam_watering.png';
  static const celebrating = 'assets/mascot/mam_celebrating.png';
  static const trophy = 'assets/mascot/mam_trophy.png';
  static const laptop = 'assets/mascot/mam_laptop.png';
  static const guiding = 'assets/mascot/mam_guiding.png';

  // Optional specialized PNGs.
  static const selfDiscovery = 'assets/mascot/mam_self_discovery.png';
  static const futureSeed = 'assets/mascot/mam_future_seed.png';
  static const fourResources = 'assets/mascot/mam_four_resources.png';
  static const optimisticView = 'assets/mascot/mam_optimistic_view.png';
  static const connectingResources =
      'assets/mascot/mam_connecting_resources.png';
  static const creativePaths = 'assets/mascot/mam_creative_paths.png';
  static const journeyMap = 'assets/mascot/mam_journey_map.png';
  static const choice = 'assets/mascot/mam_choice.png';
  static const realCase = 'assets/mascot/mam_real_case.png';
  static const smallStep = 'assets/mascot/mam_small_step.png';

  // Older official WebP assets retained as safe fallbacks.
  static const _oldQuestioning = 'assets/mascot/mam_questioning.webp';
  static const _oldLike = 'assets/mascot/mam_like.webp';
  static const _oldSayHi = 'assets/mascot/mam_say_hi.webp';
  static const _oldReading = 'assets/mascot/mam_reading.webp';
  static const _oldWriting = 'assets/mascot/mam_writing.webp';
  static const _oldLaptop = 'assets/mascot/mam_laptop.webp';
  static const _oldHoping = 'assets/mascot/mam_hoping.webp';
  static const _oldFighting = 'assets/mascot/mam_fighting.webp';

  static String forPose(MamPose pose) {
    return switch (pose) {
      MamPose.hello => guiding,
      MamPose.journey => journeyMap,
      MamPose.book => reading,
      MamPose.thinking => thinking,
      MamPose.search => searching,
      MamPose.happy => success,
      MamPose.confused => confused,
      MamPose.goal => planning,
      MamPose.reflection => reflecting,
      MamPose.media => laptop,
      MamPose.challenge => keepGoing,
      MamPose.celebration => celebrating,
      MamPose.planning => planning,
      MamPose.confident => confident,
      MamPose.keepGoing => keepGoing,
      MamPose.idea => idea,
      MamPose.problemSolving => problemSolving,
      MamPose.prototyping => prototyping,
      MamPose.creatingValue => creatingValue,
      MamPose.watering => watering,
      MamPose.trophy => trophy,
      MamPose.guiding => guiding,
      MamPose.selfDiscovery => selfDiscovery,
      MamPose.futureSeed => futureSeed,
      MamPose.fourResources => fourResources,
      MamPose.optimisticView => optimisticView,
      MamPose.connectingResources => connectingResources,
      MamPose.creativePaths => creativePaths,
      MamPose.journeyMap => journeyMap,
      MamPose.choice => choice,
      MamPose.realCase => realCase,
      MamPose.smallStep => smallStep,
    };
  }

  static String fallbackForPose(MamPose pose) {
    return switch (pose) {
      MamPose.book => _oldReading,
      MamPose.reflection => _oldWriting,
      MamPose.media => _oldLaptop,
      MamPose.challenge ||
      MamPose.keepGoing ||
      MamPose.prototyping =>
        _oldFighting,
      MamPose.happy ||
      MamPose.confident ||
      MamPose.celebration ||
      MamPose.trophy =>
        _oldLike,
      MamPose.search ||
      MamPose.thinking ||
      MamPose.confused ||
      MamPose.choice ||
      MamPose.selfDiscovery ||
      MamPose.problemSolving =>
        _oldQuestioning,
      MamPose.goal ||
      MamPose.planning ||
      MamPose.futureSeed ||
      MamPose.fourResources ||
      MamPose.optimisticView ||
      MamPose.connectingResources ||
      MamPose.creativePaths ||
      MamPose.idea ||
      MamPose.creatingValue ||
      MamPose.watering ||
      MamPose.journey ||
      MamPose.journeyMap ||
      MamPose.smallStep =>
        _oldHoping,
      MamPose.hello || MamPose.guiding || MamPose.realCase => _oldSayHi,
    };
  }
}

/// Single integration point for official Mầm artwork.
///
/// The primary PNG is used when available. If that specific new file has not
/// been added yet, the widget falls back to an older official WebP so the UI
/// never becomes blank during the migration.
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
    final child = SizedBox.square(
      dimension: size,
      child: Image.asset(
        MascotAssets.forPose(pose),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => Image.asset(
          MascotAssets.fallbackForPose(pose),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
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
