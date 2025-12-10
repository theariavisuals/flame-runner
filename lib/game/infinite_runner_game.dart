import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../components/player.dart';
import '../components/infinite_ground.dart';
import '../components/obstacle.dart';
import '../managers/obstacle_manager.dart';

class InfiniteRunnerGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  late Player player;
  late final InfiniteGround ground;
  
  AudioPlayer? _bgmPlayer;
  
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  double _scoreTracker = 0;
  
  // Difficulty Scaling
  double currentSpeed = 700.0;
  int _lastSpeedMilestone = 0;
  
  bool isPlaying = false;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // Sky blue

  @override
  Future<void> onLoad() async {
    // Basic settings
    camera.viewfinder.anchor = Anchor.topLeft;

    // Add Parallax Background
    final parallax = await loadParallaxComponent(
      [
        ParallaxImageData('NightBackground.png'),
      ],
      baseVelocity: Vector2(100, 0), // Slower than ground (depth effect)
      velocityMultiplierDelta: Vector2(1.5, 0),
    );
    add(parallax);

    // Add ground
    ground = InfiniteGround();
    add(ground);

    // Start BGM loop (Stop existing first)
    // _bgmPlayer = await FlameAudio.loop('Neon Velocity.mp3', volume: 0.5); // Start music on game start?
    // User asked for "background of title screen like actual gameplay". 
    // Usually title has music too? Let's assume Silence or same music?
    // Current logic: startGame starts music.
    
    // Don't pause! Let it run for background animation.
    // pauseEngine();
    
    // Preload audio
    await FlameAudio.audioCache.loadAll(['Neon Velocity.mp3', 'Neon Velocity Title.mp3']);

    // Start Title Music
    _bgmPlayer = await FlameAudio.loop('Neon Velocity Title.mp3', volume: 0.5);
  }

  void goToTitle() async {
    // Reset State
    isPlaying = false;
    currentSpeed = 700.0;
    _scoreTracker = 0;
    scoreNotifier.value = 0;
    
    // Clear entities
    children.whereType<Player>().forEach((p) => p.removeFromParent());
    children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
    children.whereType<ObstacleManager>().forEach((m) => m.removeFromParent());
    
    // UI
    overlays.remove('GameOver');
    overlays.remove('Hud');
    overlays.add('MainMenu');
    
    // Ensure engine runs for background animation
    resumeEngine();
    
    // Optional: Stop BGM if title should be silent, or keep if title needs music
    // For now, stop to separate "gameplay music" from "title"
    _bgmPlayer?.stop();
    _bgmPlayer = await FlameAudio.loop('Neon Velocity Title.mp3', volume: 0.5);
  }

  // Called from Main Menu
  void showCharacterSelection() {
     overlays.remove('MainMenu');
     overlays.add('CharacterSelection');
  }

  // Called from Character Selection
  void startRun(CharacterType charType) async {
    overlays.remove('CharacterSelection');
    overlays.add('Hud');
    
    isPlaying = true;
    
    // Add selected player
    // Force cleanup of any lingering players (due to paused engine)
    children.whereType<Player>().forEach((p) => p.removeFromParent());
    
    player = Player(characterType: charType);
    add(player);
    
    // Start BGM loop (Stop existing first)
    _bgmPlayer?.stop();
    _bgmPlayer = await FlameAudio.loop('Neon Velocity.mp3', volume: 0.5);
    
    // Ensure manager is present
    if (children.whereType<ObstacleManager>().isEmpty) {
      add(ObstacleManager());
    }
    
    resumeEngine();
  }

  void startGame() async {
    // Legacy mapping or used by MainMenuOverlay
    showCharacterSelection();
  }

  void resetGame() {    
    _bgmPlayer?.stop();
    
    overlays.remove('GameOver');
    overlays.add('Hud');
    
    // Reset Logic
    scoreNotifier.value = 0;
    _scoreTracker = 0;
    isPlaying = true;
    
    // Reset Speed
    currentSpeed = 700.0;
    _lastSpeedMilestone = 0;
    
    // Reset entities
    children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
    children.whereType<Player>().forEach((p) => p.removeFromParent());
    
    // Manager handled in startGame
    
    startGame();
  }

  void gameOver() {
    _bgmPlayer?.stop();
    // Play Title music? Or Silence? Typically silence or sad music.
    // Let's keep silence until they go back to title or retry.
    
    isPlaying = false;
    pauseEngine();
    // overlays.remove('Hud'); // Keep HUD visible
    overlays.add('GameOver');
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isPlaying) return; // Only process game logic if playing
    
    // Score update
    _scoreTracker += dt * 50; // Points based on distance/time (tune this?) 
    // Actually let's keep it simple: 10 points per sec was slow. 
    // If speed is 700, maybe points should match pixels? 
    // Let's stick to previous logic or simple time. 
    // Previous was: _scoreTracker += dt * 10;
    // Let's make it faster to hit 500: 100 pts/sec
    scoreTrackerUpdate(dt);
    
    // Difficulty Scaling
    if (scoreNotifier.value > _lastSpeedMilestone + 500) {
      currentSpeed += 50;
      _lastSpeedMilestone = (scoreNotifier.value ~/ 500) * 500;
      // print('Speed Up! Score: ${_lastSpeedMilestone}, Speed: $currentSpeed'); // Removed log
      
      // Speed up music - DISABLED due to stutter on Windows
      /*
      // Base speed 700 = 1.0x. 
      // Ratio = current / 700.
      final double playbackRate = currentSpeed / 700.0;
      _bgmPlayer?.setPlaybackRate(playbackRate);
      */
    }
    
    // Simple collision check
    for (final child in children) {
      if (child is Obstacle) {
        if (player.toRect().overlaps(child.toRect())) {
          gameOver();
        }
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    player.jump();
    player.isGliding = true; // Start gliding check
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    player.isGliding = false; // Stop gliding
    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    player.isGliding = false; // Stop gliding
    super.onTapCancel(event);
  }

  void scoreTrackerUpdate(double dt) {
     _scoreTracker += dt * 100; // 100 points per second
     scoreNotifier.value = _scoreTracker.toInt();
  }
}
