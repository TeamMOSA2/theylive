import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'game_const.dart';

class GridMap extends PositionComponent {
  // マップの幅と高さを指定する
  GridMap(width, height)
      : super(
          size: Vector2(-(width / 2), -(height / 2)),
        );

  final Paint _gridPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..color = const Color.fromARGB(40, 230, 230, 230);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _drawGrid(canvas, const Size(gameScreenWidth, gameScreenHeight));

    // 試験様の中央線
    //_drawAxis(canvas, const Size(gameScreenWidth, gameScreenHeight));
  }

  void _drawAxis(Canvas canvas, Size size) {
    _gridPaint
      ..color = Colors.green
      ..strokeWidth = 1.5;
    canvas.drawLine(
        Offset(-size.width / 2, 0), Offset(size.width / 2, 0), _gridPaint);
    canvas.drawLine(
        Offset(0, -size.height / 2), Offset(0, size.height / 2), _gridPaint);
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(0 - 7.0, size.height / 2 - 10), _gridPaint);
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(0 + 7.0, size.height / 2 - 10), _gridPaint);
    canvas.drawLine(
        Offset(size.width / 2, 0), Offset(size.width / 2 - 10, 7), _gridPaint);
    canvas.drawLine(
        Offset(size.width / 2, 0), Offset(size.width / 2 - 10, -7), _gridPaint);
  }

  void _drawGridRight(Canvas canvas, Size size) {
    // キャンパスの保存
    canvas.save();
    // 横線を描く
    for (int i = 0; i < size.width / 2 / space; i++) {
      canvas.drawLine(
          const Offset(0, 0), Offset(0, size.height / 2), _gridPaint);
      canvas.translate(space, 0);
    }
    // キャンパスリセット（原点リセット）
    canvas.restore();

    canvas.save();
    // 縦線を描く
    for (int i = 0; i < size.height / 2 / space; i++) {
      canvas.drawLine(
          const Offset(0, 0), Offset(size.width / 2, 0), _gridPaint);
      canvas.translate(0, space);
    }
    canvas.restore();
  }

  void _drawGrid(Canvas canvas, Size size) {
    // 右下のグリッド
    _drawGridRight(canvas, size);

    canvas.save();
    // X軸の镜像
    canvas.scale(1, -1);
    _drawGridRight(canvas, size);
    // リセット
    canvas.restore();

    canvas.save();
    // Y軸の镜像
    canvas.scale(-1, 1);
    _drawGridRight(canvas, size);
    canvas.restore();

    canvas.save();
    // 原点の镜像
    canvas.scale(-1, -1);
    _drawGridRight(canvas, size);
    canvas.restore();
  }
}
