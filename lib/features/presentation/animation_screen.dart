import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interacting_tom/features/providers/animation_state_controller.dart';
import 'package:rive/rive.dart';

class AnimationScreen extends ConsumerStatefulWidget {
  const AnimationScreen({super.key});

  @override
  ConsumerState<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends ConsumerState<AnimationScreen> {
  Artboard? riveArtboard;
  SMIBool? isHearing;
  SMIBool? talk;

  @override
  void initState() {
    debugPrint('animation screen init state');
    super.initState();

    rootBundle.load('assets/bear_character.riv').then(
      (data) async {
        try {
          final file = RiveFile.import(data);
          final artboard = file.mainArtboard;
          final controller =
              StateMachineController.fromArtboard(artboard, 'State Machine 1');
          if (controller != null) {
            artboard.addController(controller);
            isHearing = controller.findSMI('Hear');
            talk = controller.findSMI('Talk');
            setState(() {
              riveArtboard = artboard;
            });
          }
        } catch (e) {
          debugPrint('Error loading Rive file: $e');
        }
      },
    );
  }

  void _toggleAnimation(AnimationState newValue) {
    debugPrint('toggle animation, is hearing: ${newValue.isHearing}');
    isHearing?.value = newValue.isHearing;
    talk?.value = newValue.isTalking;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final animState = ref.watch(animationStateControllerProvider);
    debugPrint('Built animation screen');
    _toggleAnimation(animState);

    return Center(
      child: riveArtboard == null
          ? const SizedBox()
          : Rive(
              artboard: riveArtboard!,
              alignment: Alignment.bottomCenter,
              // fit: BoxFit.cover,
            ),
    );
  }
}
