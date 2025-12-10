import 'package:flutter/material.dart';
import '../game/infinite_runner_game.dart';

class GameOverOverlay extends StatelessWidget {
  final InfiniteRunnerGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                game.resetGame();
              },
              child: const Text('Retry'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                game.goToTitle();
              },
              child: const Text('Title'),
            ),
          ],
        ),
      ),
    );
  }
}
