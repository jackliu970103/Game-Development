import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MapBounds extends PositionComponent {
  MapBounds({required Vector2 size})
      : super(position: Vector2.zero(), size: size);

  @override
  void render(Canvas canvas) {
    // 背景
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFFFCF3BB),
    );
//Color(0xFFFCF3BB)
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

    // 地圖邊框
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()
        ..color = const Color(0xFF00e5ff)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}
