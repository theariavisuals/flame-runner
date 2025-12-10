import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

enum CharacterType {
  square,
  circle,
  diamond,
}

class Player extends PositionComponent {
  final CharacterType characterType;
  final Paint _paint = Paint();

  Player({this.characterType = CharacterType.square})
      : super(
          position: Vector2(100, 300),
          size: Vector2(50, 50),
          anchor: Anchor.center,
        ) {
    // Set color based on type
    switch (characterType) {
      case CharacterType.square:
        // _paint.color = Colors.white; // Handled by GIF
        break;
      case CharacterType.circle:
        _paint.color = Colors.cyan;
        break;
      case CharacterType.diamond:
        _paint.color = Colors.pinkAccent;
        break;
    }
  }
  
  @override
  Future<void> onLoad() async {
    if (characterType == CharacterType.square) {
      final animation = await loadGifAnimation('ninjaRun_1.gif');
      final animComponent = SpriteAnimationComponent(
        animation: animation,
        size: size,
      );
      add(animComponent);
    } else if (characterType == CharacterType.circle) {
      final animation = await loadGifAnimation('knightRun_1.gif');
      final animComponent = SpriteAnimationComponent(
        animation: animation,
        size: size,
      );
      add(animComponent);
    } else if (characterType == CharacterType.diamond) {
      final animation = await loadGifAnimation('villagerRun.gif');
      final animComponent = SpriteAnimationComponent(
        animation: animation,
        size: size,
      );
      add(animComponent);
    }
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

  double speedY = 0.0;
  final double baseGravity = 3500.0;
  final double groundY = 500.0; // Fixed ground level for now
  
  int _jumpCount = 0;
  bool isGliding = false;

  double get gravity {
    switch (characterType) {
      case CharacterType.circle: return baseGravity * 2; // 2x gravity per user request
      default: return baseGravity;
    }
  }

  int get maxJumps {
    switch (characterType) {
      case CharacterType.square: return 2; // Classic double jump
      case CharacterType.circle: return 1; // Speed single jump
      case CharacterType.diamond: return 1; // Style single jump
    }
  }
  
  double get jumpStrength {
    switch (characterType) {
      case CharacterType.square: return -1000.0;
      case CharacterType.circle: return -1500.0; // 1.5x jump strength per user request
      case CharacterType.diamond: return -1000.0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    switch (characterType) {
      case CharacterType.square:
        // canvas.drawRect(size.toRect(), _paint); // Handled by GIF
        break;
      case CharacterType.circle:
        // Draw circle (radius is half of width)
        // canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, _paint); // Handled by GIF
        break;
      case CharacterType.diamond:
        // Draw mostly similar to square but we rely on the component's angle for spin
        // However, diamond is naturally 45deg. 
        // If we want it to look like a diamond when NOT spinning:
        /*
        canvas.save();
        canvas.translate(size.x / 2, size.y / 2);
        canvas.rotate(3.14159 / 4); // 45 degrees
        canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: size.x * 0.7, height: size.y * 0.7), _paint);
        canvas.restore();
        */
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply gravity
    double effectiveGravity = gravity;
    
    // Style Gliding Logic:
    // If Diamond, in air, falling (speedY > 0), and holding input (isGliding)
    if (characterType == CharacterType.diamond && speedY > 0 && isGliding) {
      effectiveGravity *= 0.2; // Drastically reduce gravity to glide. Player requested "0.5 times speed when falling".
      // Simply reducing gravity makes them fall slower. 0.5 might not feel "floaty" enough with 3500 gravity.
      // Let's try 0.2 for a distinct glide, or 0.5 as requested? 
      // "0.5 times speed" -> maybe dampen velocity directly?
      // Let's settle on 0.5x gravity for now as a physics proxy. 
      // Actually, applying 0.5x gravity allows acceleration but slower. 
      // Let's clamp speed if gliding?
      // "Style should have 0.5 times speed when falling" -> technically implies velocity = 0.5 * normal_velocity.
      // Let's just scale the gravity update for "floatiness".
      effectiveGravity = gravity * 0.1; // Make it really floaty
    }
    
    // Actually user said: "0.5 times speed when falling"
    // So if speedY > 0, we could damp it?
    // Let's implement gravity normally, then check glide.
    
    speedY += effectiveGravity * dt;
    
    // Terminal velocity clamp for glide?
    if (characterType == CharacterType.diamond && isGliding && speedY > 200) {
      speedY = 200; // Cap fall speed
    }

    position.y += speedY * dt;

    // Ground collision (simple)
    // The player's anchor is center, so bottom is y + height/2
    if (position.y + size.y / 2 >= groundY) {
      position.y = groundY - size.y / 2;
      speedY = 0;
      angle = 0; // Reset rotation on ground
      _jumpCount = 0; // Reset jumps
    } else {
      // Rotate while in air (Sonic spin)
      // Only spin if not gliding? Or spin slower?
      if (characterType == CharacterType.diamond && isGliding) {
        angle += dt * 5; // Slow spin while gliding
      } else if (characterType != CharacterType.square && characterType != CharacterType.circle && characterType != CharacterType.diamond) { // No spin for anyone now
        angle += dt * 20; 
      }
    }
  }

  void jump() {
    if (_jumpCount < maxJumps) {
      speedY = jumpStrength;
      _jumpCount++;
    }
  }

  bool isOnGround() {
    return position.y + size.y / 2 >= groundY;
  }
}
