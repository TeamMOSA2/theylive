// ゲームの状態
// 値、色を構築時に設定
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;
import 'game_const.dart';
import 'game_scoring.dart';

// 文字の表示
enum Flip {
  normal(0),
  horizontalFlip(1);
  //verticalFlip(2); // 難しすぎるので要検討

  final int flip;
  const Flip(this.flip);
}

// 円の回転する方向
enum Direction {
  unmove(0),
  right(1),
  left(2);

  final int rotation;
  const Direction(this.rotation);
}

// 論理ブロック内の円を置く矩形の大きさ
enum Volume {
  nothing(0),
  small(1),
  medium(2),
  large(3);

  final int level;
  const Volume(this.level);
}

// ボールの状態
class CircleCondition {
  final logger = Logger();

  late int number; // 数字
  late Color color; // 色
  late Flip flip; // 文字反転方向
  late Direction direction; // 回転方向
  late Volume volume; // 大きさ
  late double speed; // 回転速度
  late double delay; // アニメ開始の遅延
  static final random = math.Random();

  // 明示的な初期化付きのコンストラクタ
  CircleCondition(
      {required this.number,
      required this.color,
      required this.flip,
      required this.direction,
      required this.volume,
      required this.speed,
      required this.delay}) {}

  // 初期値が未定の時に使う名前付きのコンストラクタ
  CircleCondition.empty()
      : number = 0,
        color = Colors.red,
        direction = Direction.right,
        volume = Volume.small,
        speed = 0,
        delay = 0;

  // 大きさ以外の駒情報を乱数で作成
  static CircleCondition makeRandomCondition(Volume newVolume, int newValue) {
    final captionValue = newValue; // 表示の値(0...99)
    final colorIndex = random.nextInt(3); // 色のindex(0...2)
    int directionIndex = 0; // 回転方向(0...2)
    double speedStep = random.nextInt(70) / 10; // 回転速度(0.1 ... 8)
    double delayStep = random.nextInt(5) / 10; // アニメ開始の遅延(0.1 ... 1)
    if (speedStep <= 0.0) {
      speedStep = 0.1;
    }

    Flip flipValue = Flip.normal; // 文字反転は通常8割、水平反転2割
    if (GameScoring.level != GameLevel.easy) {
      directionIndex = random.nextInt(3); // 回転方向(0...2)
    }

    // 鏡文字はハードのみで出現
    if (GameScoring.level == GameLevel.hard) {
      final flipRandom = random.nextInt(11); // 文字反転乱数0〜10
      if (flipRandom > 7) {
        flipValue = Flip.horizontalFlip;
      }
    }

    final colors = [Colors.red, Colors.green, Colors.blue];
    //final flips = [Flip.normal, Flip.horizontalFlip, Flip.verticalFlip];
    final directions = [Direction.unmove, Direction.right, Direction.left];

    CircleCondition condition = CircleCondition(
        number: captionValue,
        color: colors[colorIndex],
        flip: flipValue,
        direction: directions[directionIndex],
        volume: newVolume,
        speed: speedStep,
        delay: delayStep);

    return condition;
  }

  // コンディションのVolume定数をVector2に変換
  Vector2 getPieceSize() {
    if (volume == Volume.small) {
      return Vector2(smallBlock, smallBlock);
    } else if (volume == Volume.medium) {
      return Vector2(mediumBlock, mediumBlock);
    } else if (volume == Volume.medium) {
      return Vector2(largeBlock, largeBlock);
    }

    return Vector2(mediumBlock, mediumBlock);
  }

  // 駒のガチャ。作成の有無を確率で行う
  bool volumeProbability(Volume newVolume) {
    final random = math.Random();
    final pickValue = random.nextInt(100);

    // 大は20%
    if (newVolume == Volume.large) {
      if (pickValue < 10) {
        return true;
      }
      return false;
    }

    // 中は40%
    if (newVolume == Volume.medium) {
      if (pickValue < 40) {
        return true;
      }
      return false;
    }

    // 小は常に作成
    return true;
  }

  // 論理ブロックの範囲内で重複しないRectの組み合わせの作成
  //List<Rect> makeParingVectors(int x, int y, Paring newParing) {
  Rect makePiece(int x, int y, Volume newVolume) {
    double blockOffset = 0; // 乱数の振れ幅
    double blockSize = 0; // 配置のサイズ
    if (newVolume == Volume.large) {
      blockSize = largeBlock;
      blockOffset = 0.2;
    } else if (newVolume == Volume.medium) {
      blockSize = mediumBlock;
      blockOffset = 0.5;
    } else if (newVolume == Volume.small) {
      blockSize = smallBlock;
      blockOffset = 2.5;
    }

    // 矩形の始点
    double left = -(gameScreenWidth / 2) +
        (x * (space * logicalBlockSize)) +
        (x * blockPadding) +
        screenWidthOffset;
    double top = -(gameScreenHeight / 2) +
        (y * (space * logicalBlockSize)) +
        (y * blockPadding) +
        screenTopOffset;

    // top/leftが画面からはみ出ない様に補正
    if (left <= -(gameScreenWidth / 2)) {
      left = -(gameScreenWidth / 2);
    }
    if (top <= -(gameScreenHeight / 2)) {
      top = -(gameScreenHeight / 2);
    }

    // right/bottmが画面からはみ出ない様に補正
    if (left >= (gameScreenWidth / 2) - blockSize) {
      left = (gameScreenWidth / 2) - blockSize;
    }
    if (top >= (gameScreenHeight / 2) - blockSize) {
      top = (gameScreenHeight / 2) - blockSize;
    }

    // 矩形の終点
    final double right = left + blockSize;
    final double bottom = top + blockSize;

    // 暫定で大のときだけ作成
    // 大ブロックは全体の20%の範囲でTopLeftに乱数を加算しておk
    int swing = (blockSize * blockOffset).floor();
    double stepX = random.nextInt(swing).toDouble();
    double stepY = random.nextInt(swing).toDouble();

    // 左端がはみ出ないなら乱数でxを左に動かす
    if (random.nextInt(3) % 2 == 0 && (left - stepX) > 0) {
      stepX = -(stepX);
      // 右端がはみ出るならxを左に動かす
    } else if ((right + stepX) > (gameScreenWidth / 2)) {
      stepX = -(stepX);
    }

    // 上端がはみ出ないなら乱数でyを上に動かす
    if (random.nextInt(3) % 2 == 0 && (top - stepY) > 0) {
      stepY = -(stepY);
      // 下端がはみ出るならyを上に動かす
    } else if ((bottom + stepY) > (gameScreenHeight / 2)) {
      stepY = -(stepY);
    }

    //List<Rect> newParingList = [];
    Rect newRect = Rect.fromPoints(Offset(left + stepX, top + stepY),
        Offset(right + stepX, bottom + stepY));
    //logger.d("[ $x, $y ]: newRect: $newRect");
    return newRect;
  }
}
