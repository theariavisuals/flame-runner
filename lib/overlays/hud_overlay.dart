import 'package:flutter/material.dart';
import '../game/infinite_runner_game.dart';

class HudOverlay extends StatelessWidget {
  final InfiniteRunnerGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // We listen to the game's score notifier (need to implement it)
    return Positioned(
      top: 20,
      left: 20,
      child: ValueListenableBuilder<int>(
        valueListenable: game.scoreNotifier,
        builder: (context, score, child) {
          return Text(
            'Score: $score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }
}
