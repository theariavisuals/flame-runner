import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class Obstacle extends PositionComponent {
  final double speed;
  
  Obstacle({
    required Vector2 position,
    required Vector2 size,
    required this.speed,
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.bottomLeft,
        );

  @override
  Future<void> onLoad() async {
    final animation = await loadGifAnimation('soldierBlock.gif');
    final animComponent = SpriteAnimationComponent(
      animation: animation,
      size: size,
    );
    add(animComponent);
  }

  Future<SpriteAnimation> loadGifAnimation(String asset) async {
    final data = await rootBundle.load('assets/images/$asset');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), allowUpscaling: false);
    final frameCount = codec.frameCount;
    final sprites = <Sprite>[];
    final stepTimes = <double>[];

    for (var i = 0; i < frameCount; i++) {
      final frame = await codec.getNextFrame();
      final image = frame.image;
      sprites.add(Sprite(image));
      stepTimes.add(frame.duration.inMilliseconds / 1000.0);
    }

    return SpriteAnimation.variableSpriteList(sprites, stepTimes: stepTimes);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;

    // Remove if off-screen
    if (position.x + size.x < -100) {
      removeFromParent();
    }
  }
}
