import 'dart:math';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'player.dart';
import 'food.dart';
import 'map_bounds.dart';

class MyGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  final String playername;
  MyGame({required this.playername});

  late Player player;
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> timeNotifier = ValueNotifier(60);
  final ValueNotifier<bool> gameOverNotifier = ValueNotifier(false);

  int get score => scoreNotifier.value;

  static const int goodFoodCount = 5;
  static const int badFoodCount = 3;
  static const int gameDuration = 60;

  // 改成動態抓取，不再寫死
  double get mapWidth => size.x;
  double get mapHeight => size.y;

  double _timeAccumulator = 0;

  @override
  Color backgroundColor() => const Color(0xFF1a1a2e);

  @override
  Future<void> onLoad() async {
    debugMode= true;
    // 移除 FixedResolutionViewport，改用預設 viewport（全螢幕）
    add(MapBounds());

    player = Player(
      position: Vector2(mapWidth / 2, mapHeight / 2),
      onEat: _onEat,
      playername: playername,
    );
    add(player);

    _spawnFood(FoodType.good, goodFoodCount);
    _spawnFood(FoodType.bad, badFoodCount);

    overlays.add('hud');
    camera.follow(player);
    // *** 不再設定 FixedResolutionViewport ***
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameOverNotifier.value) return;

    _timeAccumulator += dt;
    if (_timeAccumulator >= 1.0) {
      _timeAccumulator -= 1.0;
      timeNotifier.value -= 1;
      if (timeNotifier.value <= 0) {
        timeNotifier.value = 0;
        _endGame();
      }
    }
  }

  void _endGame() {
    gameOverNotifier.value = true;
    player.removeFromParent();
    overlays.add('gameOver');
  }

  void _onEat(int scoreDelta) {
    if (gameOverNotifier.value) return;
    scoreNotifier.value = (scoreNotifier.value + scoreDelta).clamp(0, 99999);
    final type = scoreDelta > 0 ? FoodType.good : FoodType.bad;
    _spawnFood(type, 1);
  }

  void _spawnFood(FoodType type, int count) {
    final random = Random();
    for (int i = 0; i < count; i++) {
      final pos = Vector2(
        50 + random.nextDouble() * (mapWidth - 100),
        50 + random.nextDouble() * (mapHeight - 100),
      );

      final delay = (random.nextDouble() * 0.3 * i * 1000).toInt();

      Future.delayed(Duration(milliseconds: delay), () {
        if (!gameOverNotifier.value) {
          add(Food(position: pos, type: type));
        }
      });
    }
  }

  void restartGame() {
    scoreNotifier.value = 0;
    timeNotifier.value = gameDuration;
    gameOverNotifier.value = false;
    _timeAccumulator = 0;

    children.whereType<Food>().toList().forEach((f) => f.removeFromParent());

    player = Player(
      position: Vector2(mapWidth / 2, mapHeight / 2),
      onEat: _onEat,
      playername: playername,
    );
    add(player);
    camera.follow(player);

    _spawnFood(FoodType.good, goodFoodCount);
    _spawnFood(FoodType.bad, badFoodCount);

    overlays.remove('gameOver');
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!gameOverNotifier.value) player.updateMovement(keysPressed);
    return KeyEventResult.handled;
  }
}