import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';

import 'package:infinite_run/game/infinite_runner_game.dart';

class InfiniteGround extends PositionComponent with HasGameRef<InfiniteRunnerGame> {
  late final ParallaxComponent _groundParallax;

  InfiniteGround() {
    // Ground is at Y=500.
    position = Vector2(0, 500);
  }

  @override
  Future<void> onLoad() async {
    // Use ParallaxComponent for seamless looping of the whole image
    _groundParallax = await gameRef.loadParallaxComponent(
      [
        ParallaxImageData('NightGround.png'),
      ],
      baseVelocity: Vector2(gameRef.currentSpeed, 0),
      repeat: ImageRepeat.repeatX,
      fill: LayerFill.height, // Scale image to fit height (zooms out if image is large)
      alignment: Alignment.topLeft, // Use top half of image
      // Size: width of screen, height to cover bottom
      size: Vector2(gameRef.size.x, 250), 
    );
    add(_groundParallax);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Sync speed
    _groundParallax.parallax?.baseVelocity = Vector2(gameRef.currentSpeed, 0);
  }
}
