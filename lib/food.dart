import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'my_game.dart';

enum FoodType { good, bad }

class Food extends SpriteComponent with HasGameRef<MyGame>{
  static const double foodSize = 36; // 可自行調整大小

  final FoodType type;

  // 好食物 +10，壞食物 -10
  int get scoreDelta => type == FoodType.good ? 10 : -10;

  Food({required Vector2 position, required this.type})
      : super(
          size: Vector2.all(foodSize),
          position: position,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    final imageName =
        type == FoodType.good ? 'good_food.png' : 'bad_food.png';
    sprite = await gameRef.loadSprite(imageName);

    add(CircleHitbox(
      radius: foodSize / 2,
      position: Vector2(foodSize / 2, foodSize / 2),
      anchor: Anchor.center,
    ));
  }
}
