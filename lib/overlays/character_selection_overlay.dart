import 'package:flutter/material.dart';
import '../game/infinite_runner_game.dart';
import '../components/player.dart';

class CharacterSelectionOverlay extends StatelessWidget {
  final InfiniteRunnerGame game;

  const CharacterSelectionOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CHOOSE YOUR HERO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCharacterOption(
                  context,
                  CharacterType.square,
                  Colors.white,
                  'Hanzo',
                  'ninjaRun_1.gif',
                ),
                const SizedBox(width: 20),
                _buildCharacterOption(
                  context,
                  CharacterType.circle,
                  Colors.cyan,
                  'Arthur',
                  'knightRun_1.gif',
                ),
                const SizedBox(width: 20),
                _buildCharacterOption(
                  context,
                  CharacterType.diamond,
                  Colors.pinkAccent,
                  'Tom',
                  'villagerRun.gif',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterOption(BuildContext context, CharacterType type, Color color, String label, String imageAsset) {
    return GestureDetector(
      onTap: () {
        game.startRun(type);
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/$imageAsset',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
