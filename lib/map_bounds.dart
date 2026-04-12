import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
class MapBounds extends PositionComponent with HasGameRef {
  MapBounds() : super(position: Vector2.zero());

  double _pulseTime = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = gameRef.size;
  }

  // 視窗 resize 時自動更新
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFFFCF3BB),
    );
    final gridPaint = Paint()
      ..color = const Color(0xFF2a2a4a)
      ..strokeWidth = 1;

    const gridSize = 50.0;
    for (double x = 0; x <= size.x; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), gridPaint);
    }
    for (double y = 0; y <= size.y; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), gridPaint);
    }
  }
}