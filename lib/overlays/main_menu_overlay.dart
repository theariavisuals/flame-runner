import 'package:flutter/material.dart';
import '../game/infinite_runner_game.dart';

class MainMenuOverlay extends StatelessWidget {
  final InfiniteRunnerGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title Image
          Image.asset(
            'assets/images/Title_A.png',
            width: 400, // Limit width to prevent overflow
          ),
          const SizedBox(height: 50),
          // Start Button Image
          GestureDetector(
            onTap: () {
              game.startGame();
            },
            child: Image.asset(
              'assets/images/StartButton_A.png',
              width: 200, // Reasonable button size
            ),
          ),
        ],
      ),
    );
  }
}
