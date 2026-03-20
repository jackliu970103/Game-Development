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
  late Player player;
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  int get score => scoreNotifier.value;

  static const int goodFoodCount = 5;
  static const int badFoodCount = 3;
  static const double mapWidth = 800;
  static const double mapHeight = 600;

  @override
  Color backgroundColor() => const Color(0xFF1a1a2e);

  @override
  Future<void> onLoad() async {

    add(MapBounds(size: Vector2(mapWidth, mapHeight)));

    player = Player(
      position: Vector2(mapWidth / 2, mapHeight / 2),
      onEat: _onEat,
    );
    add(player);

    // 初始生成好食物與壞食物
    _spawnFood(FoodType.good, goodFoodCount);
    _spawnFood(FoodType.bad, badFoodCount);

    overlays.add('hud');

    camera.follow(player);
    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(mapWidth, mapHeight),
    );
  }

  void _onEat(int scoreDelta) {
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
      add(Food(position: pos, type: type));
    }
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    player.updateMovement(keysPressed);
    return KeyEventResult.handled;
  }
}
