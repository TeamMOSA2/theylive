//import 'dart:math';

import 'dart:math';

import 'game_const.dart';
import 'game_scoring.dart';
import 'my_game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/geometry.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'circle_condition.dart';
import 'dart:math' as math;

class CircleRotator extends PositionComponent
    with TapCallbacks, HasGameRef<MyGame> {
  CircleRotator({
    required super.position,
    required super.size,
    required this.condition,
    this.thickness = 8,
  })  : assert(size!.x == size.y),
        super(anchor: Anchor.center);

  final double thickness;
//  final double rotationSpeed;
  final CircleCondition condition;

  final TextPaint smallTextPaint = TextPaint(
    style: const TextStyle(
        fontFamily: 'PixelMplus', fontSize: 32.0, color: Colors.white),
  );
  final TextPaint mediumTextPaint = TextPaint(
    style: const TextStyle(
        fontFamily: 'PixelMplus', fontSize: 64.0, color: Colors.white),
  );
  final TextPaint largeTextPaint = TextPaint(
    style: const TextStyle(
        fontFamily: 'PixelMplus', fontSize: 96.0, color: Colors.white),
  );

  final logger = Logger();

  CircleCondition getCondition() {
    return condition;
  }

  @override
  void onLoad() {
    super.onLoad();
    //const circle = math.pi * 2;
    if (condition.flip == Flip.horizontalFlip) {
      flipHorizontally();
      //} else if (condition.flip == Flip.verticalFlip) {
      //  flipHorizontally();
    }

    //final sweep = circle / gameRef.gameColors.length;
    final random = math.Random();
    //const double sweep = (circle / 2);
    final double initAngle = (random.nextInt(628) / 10);
    //final double blinkDuration = (random.nextInt(20) / 10);

    TextPaint textPaint = smallTextPaint;
    if (condition.volume == Volume.large) {
      textPaint = largeTextPaint;
    } else if (condition.volume == Volume.medium) {
      textPaint = mediumTextPaint;
    }

    add(CircleArc(
        color: condition.color,
        startAngle: initAngle,
        //sweepAngle: sweep,
        textPaint: textPaint,
        condition: condition));
/*
    if( GameScoring.level == GameLevel.normal || GameScoring.level == GameLevel.hard){
      
    }
*/
    // 右回り
    if (condition.direction == Direction.right) {
      final clockwiseEffectController = EffectController(
        speed: condition.speed,
        startDelay: condition.delay,
        infinite: true,
      );

      final rotateEffect = RotateEffect.by(tau, clockwiseEffectController);
      add(rotateEffect);
      // 左回り
    } else if (condition.direction == Direction.left) {
      final reverseClockwiseEffectController = EffectController(
        duration: 0,
        //speed: condition.speed,
        reverseSpeed: condition.speed,
        startDelay: condition.delay,
        infinite: true,
      );
      final rotateEffect =
          RotateEffect.by(tau, reverseClockwiseEffectController);
      add(rotateEffect);
      // 回転しない
    } else if (condition.direction == Direction.unmove) {}
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (GameScoring.signal != GameSignal.playing) {
      logger.d("CircleRotator onTapUp skip");
      return;
    }

    logger.d("onTapUp");
    logger.d("circleCondition: ${condition.number}");
    logger.d("circleCondition: ${condition.color.toString()}");
//    logger.d("circleCondition: ${GameScoring.question['TopCaption']}");
    // 採点処理
    bool result = GameScoring.judgment(condition);

    // 全ステージを周回したらゲーム終了
    if (GameScoring.stageIndex >= GameScoring.gameLevels.length) {
      gameRef.showGameOverMenu();
      return;
    }

    // ステージクリアの回答数を満たしたら次ステージへ
    if (GameScoring.correct >= clearThreshould && result == true) {
      gameRef.overlays.add('ClearMenu');
      return;
    }

    logger.d("Scoring: $result");
    // 素数、最小、最大、次の数字、は1回で終了
    if (GameScoring.rule == GameRule.minimum ||
        GameScoring.rule == GameRule.maximum ||
        GameScoring.rule == GameRule.next ||
        GameScoring.rule == GameRule.previous ||
        GameScoring.rule == GameRule.primeNumber ||
        GameScoring.rule == GameRule.notPrimeNumber ||
        GameScoring.rule == GameRule.minPrimeNumber ||
        GameScoring.rule == GameRule.maxPrimeNumber) {
      if (result == true) {
        gameRef.hideQuestion();

        GameScoring.removeNumber(condition, this);
        final scaleEffect = ScaleEffect.by(
            Vector2.all(0), EffectController(duration: 0.1, infinite: false),
            onComplete: () => {
                  // クリアしていなければ次の出題を開始
                  if (GameScoring.correct < clearThreshould)
                    {
                      gameRef.nextQuestion(), // 次の出題
                    },
                  removeFromParent(),
                });
        add(scaleEffect);
      }
    }
  }
}

class CircleArc extends PositionComponent with ParentIsA<CircleRotator> {
  final Color color;
  final double startAngle;
  //final double sweepAngle;
  final TextPaint textPaint;
  final CircleCondition condition;

  CircleArc(
      {required this.color,
      required this.startAngle,
      //required this.sweepAngle,
      required this.textPaint,
      required this.condition})
      : super(anchor: Anchor.center);

  @override
  void onMount() {
    size = parent.size;
    position = size / 2;
    super.onMount();
  }

  @override
  void render(Canvas canvas) {
    //グラデーション付きの円グラフ
    final redGradientColor = <Color>[
      Colors.red,
      Colors.red.shade200,
    ];

    final greenGradientColor = <Color>[
      Colors.green,
      Colors.green.shade200,
    ];

    final blueGradientColor = <Color>[
      Colors.blue,
      Colors.blue.shade200,
    ];

    List<Color> gradientColor = <Color>[];
    if (condition.color == Colors.red) {
      gradientColor = redGradientColor;
    } else if (condition.color == Colors.green) {
      gradientColor = greenGradientColor;
    } else if (condition.color == Colors.blue) {
      gradientColor = blueGradientColor;
    }

    //グラデーションの境目の位置
    final gradientStops = [0.1, 0.9];
    final centerOffset = Offset(parent.width / 2, parent.height / 2);
    final radius = min(parent.width / 2, parent.height / 2);

    // 衝突判定用の矩形と天地判定マーク
    double blockLength = 0.0;
    double markTop = 0;
    if (condition.volume == Volume.large) {
      blockLength = largeBlock;
      markTop = -10;
    } else if (condition.volume == Volume.medium) {
      blockLength = mediumBlock;
      markTop = parent.height / 6;
    } else if (condition.volume == Volume.small) {
      blockLength = smallBlock;
      markTop = parent.height / 5;
    }

    // 確認用の矩形
/*
    Rect boxOuterRect = Rect.fromPoints(
        Offset(center.x - (blockLength / 2), center.y - (blockLength / 2)),
        Offset(center.x + (blockLength / 2), center.y + (blockLength / 2)));
    canvas.drawRect(
        boxOuterRect, Paint()..color = Colors.green.withOpacity(0.1));
*/
    final shaderRect =
        Rect.fromCircle(center: centerOffset, radius: radius / 1.4);
    final pie = Paint();
    pie.shader = LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: gradientColor,
            stops: gradientStops)
        .createShader(shaderRect);

    canvas.drawCircle(shaderRect.center, blockLength / 2.4, pie);
    // 上の方に天地判定のマークをつける
    textPaint.render(canvas, "・", Vector2(parent.width / 2, markTop),
        anchor: Anchor.center);

    // 数字の表示
    textPaint.render(canvas, condition.number.toString(),
        Vector2(parent.width / 2, parent.height / 2),
        anchor: Anchor.center);
  }
}
