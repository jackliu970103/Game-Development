import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'my_game.dart';

enum FoodType { good, bad }

class Food extends SpriteComponent with HasGameRef<MyGame> {

  static const double goodFoodSize = 75;
  static const double badFoodSize = 75;

  final FoodType type;
  final Vector2 _targetPosition;
  bool _isEaten = false;

  static const List<String> _goodImages = [
    'good1.png', 'good2.png', 'good3.png', 'good4.png', 'good5.png',
  ];

  static const List<String> _badImages = [
    'bad1.png', 'bad2.png', 'bad3.png', 'bad4.png',
    'bad5.png', 'bad6.png', 'bad7.png', 'bad8.png',
  ];

  int get scoreDelta => type == FoodType.good ? 10 : -10;
  bool get isEaten => _isEaten;

  static double _sizeForType(FoodType type) =>
      type == FoodType.good ? goodFoodSize : badFoodSize;

  Food({required Vector2 position, required this.type})
      : _targetPosition = position.clone(),
        super(
        size: Vector2.all(_sizeForType(type)),
        position: Vector2(position.x, -_sizeForType(type)),
        anchor: Anchor.center,
      );

  @override
  Future<void> onLoad() async {
    final random = Random();
    final imageName = type == FoodType.good
        ? _goodImages[random.nextInt(_goodImages.length)]
        : _badImages[random.nextInt(_badImages.length)];

    sprite = await gameRef.loadSprite(imageName);

    final currentSize = _sizeForType(type);

    add(CircleHitbox(
      radius: currentSize / 2,
      position: Vector2(currentSize / 2, currentSize / 2),
      anchor: Anchor.center,
    ));

    add(
      MoveToEffect(
        _targetPosition,
        EffectController(duration: 0.7, curve: Curves.bounceOut),
      ),
    );
  }

  void playEatAnimation() {
    if (_isEaten) return;
    _isEaten = true;

    children.whereType<CircleHitbox>().forEach((h) => h.removeFromParent());

    add(
      ScaleEffect.to(
        Vector2.all(0),
        EffectController(duration: 0.25, curve: Curves.easeIn),
      ),
    );

    add(
      OpacityEffect.to(
        0,
        EffectController(duration: 0.25, curve: Curves.easeIn),
        onComplete: removeFromParent,
      ),
    );
  }
}