import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/infinite_runner_game.dart';
import 'overlays/main_menu_overlay.dart';
import 'overlays/game_over_overlay.dart';
import 'overlays/hud_overlay.dart';
import 'overlays/character_selection_overlay.dart';

void main() {
  runApp(MaterialApp(
    home: GameWidget<InfiniteRunnerGame>.controlled(
      gameFactory: InfiniteRunnerGame.new,
      initialActiveOverlays: const ['MainMenu'],
      overlayBuilderMap: {
        'MainMenu': (_, game) => MainMenuOverlay(game: game),
        'GameOver': (_, game) => GameOverOverlay(game: game),
        'Hud': (_, game) => HudOverlay(game: game),
        'CharacterSelection': (_, game) => CharacterSelectionOverlay(game: game),
      },
    ),
  ));
}
