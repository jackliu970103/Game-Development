import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class MapBounds extends PositionComponent {
  MapBounds({required Vector2 size})
      : super(position: Vector2.zero(), size: size);

  double _pulseTime = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _pulseTime += dt;
  }

  @override
  void render(Canvas canvas) {
    // 背景
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFFFCF3BB),
    );

    // 格線
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

    // 脈衝邊框動畫：透明度隨 sin 波動
    final pulse = (sin(_pulseTime * 2.5) + 1) / 2; // 0.0 ~ 1.0
    final borderColor = Color.lerp(
      const Color(0xFF00e5ff),
      const Color(0xFFff00cc),
      pulse,
    )!;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 + pulse * 2, // 邊框寬度也跟著脈動
    );
  }
}