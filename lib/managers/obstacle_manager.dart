import 'dart:math';
import 'package:flame/components.dart';
import 'package:infinite_run/components/obstacle.dart';
import 'package:infinite_run/game/infinite_runner_game.dart';

class ObstacleManager extends Component with HasGameRef<InfiniteRunnerGame> {
  late Timer _timer;
  final Random _random = Random();

  ObstacleManager() {
    _timer = Timer(2.0, onTick: _spawnObstacle, repeat: true);
  }

  void _spawnObstacle() {
    // Dynamic spawn rate: Distance = Speed * Time
    // We want a gap of roughly 400-900 pixels
    final double minGap = 400.0;
    final double maxGap = 900.0;
    final double gap = minGap + _random.nextDouble() * (maxGap - minGap);
    
    // Time = Distance / Speed
    _timer.limit = gap / gameRef.currentSpeed;

    // Create obstacle
    final obstacle = Obstacle(
      position: Vector2(gameRef.size.x + 100, 500), // Ground Y is 500
      size: Vector2(50, 50),
      speed: gameRef.currentSpeed,
    );
    
    gameRef.add(obstacle);
  }

  @override
  void onMount() {
    super.onMount();
    _timer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer.update(dt);
  }
}
