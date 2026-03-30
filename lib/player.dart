import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'food.dart';
import 'my_game.dart';

class Player extends SpriteComponent
    with HasGameRef<MyGame>, CollisionCallbacks {
  final String playername;
  static const double speed = 200;
  static const double playerSize = 100;

  final void Function(int scoreDelta) onEat;
  Vector2 _velocity = Vector2.zero();

  Player({required Vector2 position, required this.onEat, required this.playername})
      : super(
    size: Vector2.all(playerSize),
    position: position,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    var name = "";
    switch (playername) {
      case "assets/images/redStand.png":
        name = "redRunning.png";
        break;
      case "assets/images/blueStand.png":
        name = "blueRunning.png";
        break;
      case "assets/images/grayStand.png":
        name = "grayRunning.png";
        break;
      case "assets/images/player.png":
        name = "yellowRunning.png";
        break;
    }
    sprite = await gameRef.loadSprite(name);

    add(CircleHitbox(
      radius: playerSize / 4,
      position: Vector2(50, 50),
      anchor: Anchor.center,
    ));
  }

  void updateMovement(Set<LogicalKeyboardKey> keysPressed) {
    double dx = 0;
    double dy = 0;

    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW)) {
      dy = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS)) {
      dy = 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      dx = -1;
      if (isFlippedHorizontally) flipHorizontally();
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      dx = 1;
      if (!isFlippedHorizontally) flipHorizontally();
    }

    _velocity = Vector2(dx, dy);
    if (_velocity.length > 0) {
      _velocity.normalize();
      _velocity.scale(speed);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(_velocity * dt);

    position.x = position.x.clamp(playerSize / 2, MyGame.mapWidth - playerSize / 2);
    position.y = position.y.clamp(playerSize / 2, MyGame.mapHeight - playerSize / 2);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Food && !other.isEaten) {
      other.playEatAnimation();
      onEat(other.scoreDelta);  // 更新分數
    }
  }
}