import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'game_const.dart';
import 'game_scoring.dart';

class TimerBar extends PositionComponent {
  double progress = 0.0; // 0.0〜1.0で100%
  final TextPaint smallTextPaint = TextPaint(
    style: const TextStyle(
        fontFamily: 'PixelMplus', fontSize: 20.0, color: Colors.white),
  );

  TimerBar(width, height)
      : super(
          size: Vector2(-(width / 2), -(height / 2)),
        );

  @override
  void render(Canvas canvas) {
    canvas.save();

    canvas.scale(-1, -1);
    final proglessWidth = timerbarWidth * progress;
    // 残り時間の青いバー
/*
    canvas.drawRect(
      Rect.fromPoints(const Offset(0, gameScreenHeight / 2),
          const Offset(timerbarWidth, meterHeight)),
      Paint()..color = Colors.blue,
    );
*/

    canvas.drawRect(
      const Rect.fromLTWH(
          -(timerbarWidth / 2),
          (gameScreenHeight / 2) - timerHeightOffset,
          timerbarWidth,
          meterHeight),
      Paint()..color = Colors.blue,
    );

    // 時間経過の赤いバー
    canvas.drawRect(
      Rect.fromLTWH(
          -(timerbarWidth / 2),
          (gameScreenHeight / 2) - timerHeightOffset,
          proglessWidth,
          meterHeight),
      Paint()..color = Colors.red,
    );
    canvas.restore();

    smallTextPaint.render(
        canvas,
        "${GameScoring.correct}/$clearThreshould",
        Vector2(0,
            -(gameScreenHeight / 2) + (timerHeightOffset - quotaHeightOffset)),
        anchor: Anchor.center);

    super.render(canvas);
  }
}
