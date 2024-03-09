//import 'dart:math';
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;

import 'circle_rotator.dart';
import 'circle_condition.dart';
import 'grid_map.dart';
//import 'expand_circle.dart';
import 'game_scoring.dart';
import 'timer_bar.dart';
import 'game_const.dart';

class MyGame extends FlameGame with TapCallbacks {
  late List<CircleRotator> pieces = []; // 配置した駒の位置
  late List<Rect> pieceRects = []; // 配置した駒の位置
  // 構築した数字のソート済み配列
  List<int> redNumbers = []; // 赤の数字
  List<int> greenNumbers = []; // 緑の数字
  List<int> blueNumbers = []; // 青の数字
  List<int> allNumbers = []; // 全部の色の数字
  final random = math.Random();
  late List<Map<String, dynamic>> history; // 回答済みのクイズ
  late TextComponent topQuestionText;
  late TextComponent midQuestionText;
  late TextComponent bottomQuestionText;
  String topQuestionCaption = "";
  String midQuestionCaption = "";
  String bottomQuestionCaption = "";
  String countdownCaption = "";
  final logger = Logger();
  late TimerBar timerBar;

  late TimerComponent progressTimeComponent; // ゲーム時間のタイマー
  late TimerComponent countdownTimeComponent; // ゲーム開始のタイマー
/*
  final labelComponent = PositionComponent(
      size: Vector2(gameScreenWidth, questionTextHeight),
      position: Vector2(gameScreenWidth / 2, questionTextHeight),
      anchor: Anchor.bottomCenter,
      priority: 1000);
*/
  //final pixelFontStyle = const TextStyle(fontSize: 20, letterSpacing: 0.1, height: 1.4, fontFamily: 'PixelMplus');
  MyGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameScreenWidth,
            height: gameScreenHeight,
          ),
        );

  @override
  Future<void> onLoad() async {
    await FlameAudio.audioCache.loadAll([
      'sfx/countdown-3.mp3',
      'sfx/correct_01.mp3',
      'sfx/wrong_01.mp3',
      'sfx/question.mp3',
      'sfx/failed.mp3',
      'sfx/nc214585.mp3',
      'sfx/rappa.mp3',
      'sfx/wadaiko.mp3',
      'bgm/csikos.mp3',
    ]);

    FlameAudio.bgm.stop();
  }

  @override
  Color backgroundColor() => const Color(0xff222222);

  @override
  void onRemove() {
    logger.d("MyGame::onRemove");
  }

  @override
  void onMount() {
    world.add(GridMap(gameScreenWidth, gameScreenHeight));

    timerBar = TimerBar(gameScreenWidth, questionTextHeight);
    world.add(timerBar);

    makeQuestionText();
    changeQuestionTextColor();

    super.onMount();
  }

  @override
  void update(double dt) {
    //final cameraY = camera.viewfinder.position.y;
    super.update(dt);
    //logger.d("progress: ${GameScoring.timerProgress}");

    if (GameScoring.signal == GameSignal.playing) {
      //timerBar.setProgress(timerProgress);
      timerBar.progress = GameScoring.timerProgress;

      if (GameScoring.question['Result'] != null) {
        topQuestionText.text = GameScoring.question['Result'];
      } else {
        topQuestionText.text = GameScoring.question['TopCaption'];
        midQuestionText.text = GameScoring.question['MidCaption'];
        bottomQuestionText.text = GameScoring.question['BottomCaption'];
      }
    } else if (GameScoring.signal == GameSignal.ready) {
      timerBar.progress = GameScoring.timerProgress;
      topQuestionText.text = countdownCaption;
      midQuestionText.text = "";
      bottomQuestionText.text = "";
    } else if (GameScoring.signal == GameSignal.timeup) {
      topQuestionText.text = topQuestionCaption;
      midQuestionText.text = "";
      bottomQuestionText.text = "";
    } else if (GameScoring.signal == GameSignal.over) {
      topQuestionText.text = topQuestionCaption;
      midQuestionText.text = "";
      bottomQuestionText.text = "";
    } else if (GameScoring.signal == GameSignal.clear) {
      topQuestionText.text = topQuestionCaption;
      midQuestionText.text = "";
      bottomQuestionText.text = "";
      // テスト用
    } else {
      //topQuestionText.text = "TOP:01234567890ABCDEFG";
      //midQuestionText.text = "MID:OOOOOOOOOOOOOOOOOO";
      //bottomQuestionText.text = "BOT:ZZZZZZZZZZZZZZZ";
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    //myPlayer.jump();
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    // Do something in response to a tap event
    super.onTapUp(event);
  }

  // 作成済み駒の矩形の重なりを確認する関数
  bool areRectanglesOverlapping(Rect pieceRect) {
    //logger.d("================");
    //logger.d("pieceRect : $pieceRect");
    for (int i = 0; i < pieceRects.length; i++) {
      Rect existPieceRect = pieceRects[i];
      //logger.i("  pieceRects[$i] : $existPieceRect");
      // 駒の中央は衝突扱いにする
      if (existPieceRect.size.width >= largeBlock &&
          pieceRect.size.width <= largeBlock) {
        Rect centerRect = Rect.fromPoints(
            Offset(existPieceRect.center.dx - (mediumBlock / 2),
                existPieceRect.center.dy - (mediumBlock / 2)),
            Offset(existPieceRect.center.dx + (mediumBlock / 2),
                existPieceRect.center.dy + (mediumBlock / 2)));
        if (centerRect.overlaps(pieceRect) == true) {
          return true;
        }
      }

      // 2サイズ以上大きい駒で中央に近くなければ衝突判定をスキップする
      // 大に小は重なってOK、大に中 or 中に小の重なりはNG
      if (existPieceRect.size.width >
          //(pieceRect.size.width + (mediumBlock - smallBlock))) {
          (pieceRect.size.width + smallBlock)) {
        continue;
      }

      if (pieceRect.overlaps(existPieceRect) == true) {
        //logger.i("****  pieceRects[$i] conflict!");
        return true;
      }
    }
    return false;
  }

  // 未使用の番号を作成
  int makeUnusedNumber() {
    int newValue = 0;
    bool isExist = false;
    do {
      newValue = random.nextInt(100);
      isExist = allNumbers.contains(newValue);
    } while (isExist);

    return newValue;
  }

  // 駒の削除
  void removeGameComponents() {
    for (int i = pieces.length - 1; i >= 0; i--) {
      pieces[i].removeFromParent();
    }

    pieces = [];
    pieceRects = [];
    redNumbers = [];
    greenNumbers = [];
    blueNumbers = [];
    allNumbers = [];
  }

  // 駒の作成。ゲームレベルで
  void generateGameComponents() {
    GameScoring.pieces = pieces;
    //GameScoring.question = currentQuestion;
    GameScoring.reds = redNumbers;
    GameScoring.greens = greenNumbers;
    GameScoring.blues = blueNumbers;
    GameScoring.all = allNumbers;

    // 左右の余白をスクリーンから減らす
    const double worldWidth = gameScreenWidth - (screenWidthOffset * 2);
    const double worldHeight = gameScreenHeight - screenTopOffset;

    // 余白を差し引いた画面で論理ブロックの数を算出
    final int logicalColumns =
        (worldWidth / (space * logicalBlockSize)).floor();
    final int logicalRows = (worldHeight / (space * logicalBlockSize)).floor();

    Vector2 pieceSize; // = Vector2(smallBlock, smallBlock);
    // 大、中、小の順番で配置する
    List<Volume> volumes = [
      Volume.large,
      Volume.medium,
      Volume.small,
    ];

    // 駒の数が30になるまで繰り返す
    int totalCount = 0;
    int largeCount = 0; // 大サイズの構築数
    int retryCount = 0; // 隙間埋めのリトライ数
    //GameScoring emptyScoring = GameScoring.empty(); // 未作成のルール
    do {
      for (int z = 0; z < volumes.length; z++) {
        //for (int z = 0; z < 1; z++) {
        Volume newVolume = volumes[z];
        // 大サイズが最大数を超えたらスキップ
        if (newVolume == Volume.large) {
          if (largeCount >= largePieceMax) {
            continue;
          }
        }

        for (int y = 0; y < logicalRows; y++) {
          for (int x = 0; x < logicalColumns; x++) {
            int newValue = makeUnusedNumber();
            CircleCondition randomCondition =
                CircleCondition.makeRandomCondition(newVolume, newValue);
            // 駒を作らなければスキップ
            bool isProbability = randomCondition.volumeProbability(newVolume);
            if (isProbability == false) {
              continue;
            }
            Rect newPieceRect = randomCondition.makePiece(x, y, newVolume);
            // 衝突が発生したときスキップする
            if (areRectanglesOverlapping(newPieceRect) == true) {
              continue;
            }

            pieceRects.add(newPieceRect);
            Vector2 newPieceVector =
                Vector2(newPieceRect.center.dx, newPieceRect.center.dy);

            pieceSize = randomCondition.getPieceSize();
            CircleRotator newPiece = CircleRotator(
              position: newPieceVector,
              size: pieceSize,
              condition: randomCondition,
            );
            pieces.add(newPiece);
            world.add(newPiece);
/*
            world.add(CircleRotator(
              position: newPieceVector,
              size: pieceSize,
              condition: randomCondition,
            ));
*/
            // 構築済みの値に追加
            allNumbers.add(newValue);

            // 赤、緑、青の構築済み配列に追加
            if (randomCondition.color == Colors.red) {
              redNumbers.add(newValue);
            } else if (randomCondition.color == Colors.green) {
              greenNumbers.add(newValue);
            } else if (randomCondition.color == Colors.blue) {
              blueNumbers.add(newValue);
            }

            // 大きい駒の個数制限
            if (newVolume == Volume.large) {
              largeCount++;
            }

            // 作成済み駒数を加算
            totalCount++;
            if (totalCount > gamePiecesMax) {
              break;
            }
          }
        }
      }
      // 構築が一巡後は小のみを構築する
      volumes = [Volume.small];
      retryCount++;
      if (retryCount > gamePiecesRetryCountMax) {
        break;
      }
    } while (totalCount < gamePiecesMax);

    allNumbers.sort();
    redNumbers.sort();
    greenNumbers.sort();
    blueNumbers.sort();

    logger.d("allNumberd after sort: $allNumbers");
    logger.d("redNumbers after sort: $redNumbers");
    logger.d("greenNumbers after sort: $greenNumbers");
    logger.d("blueNumbers after sort: $blueNumbers");
  }

  // 初回のゲーム開始のカウントダウン
  void startup() {
    List<String> easyCountDownText = ['Go!', '1', '2', '3', 'Practice ready'];
    List<String> normalCountDownText = [
      'Go!',
      '1',
      '2',
      '3',
      'Qualifier ready'
    ];
    List<String> hardCountDownText = ['Go!', '1', '2', '3', 'Finals ready'];

    List<String> countDownText = [];
    if (GameScoring.level == GameLevel.easy) {
      countDownText = easyCountDownText;
    } else if (GameScoring.level == GameLevel.normal) {
      countDownText = normalCountDownText;
    } else if (GameScoring.level == GameLevel.hard) {
      countDownText = hardCountDownText;
    }

    int countdownIndex = countDownText.length - 1;
    GameScoring.signal = GameSignal.ready;

    countdownTimeComponent = TimerComponent(
      period: 1.0,
      repeat: true,
      autoStart: true,
      //removeOnFinish: true,
      onTick: () => {
        //logger.d('countdownIndex: $countdownIndex'),
        countdownCaption = countDownText[countdownIndex],
        if (countdownIndex == 4)
          {
            FlameAudio.play('sfx/countdown-3.mp3'),
          },
        if (countdownIndex == 0) {FlameAudio.play('sfx/wadaiko.mp3'), go()},
        countdownIndex--,
      },
    );
    add(countdownTimeComponent);
  }

  // 次ステージの初期化
  void prepareNextStage() {
    resetStage();
    showQuestion();
/*
    midQuestionText.add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: fadeInSpeed),
    ));
    bottomQuestionText.add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: fadeInSpeed),
    ));
*/
    // 作成済みデータの破棄を行ってからステージ再作成
    removeGameComponents();
    generateGameComponents();
  }

  // メーターの更新処理と終了条件
  void updateTimerBar() {
    // ゲーム中だけタイマーを進める
    if (GameScoring.signal == GameSignal.playing) {
      GameScoring.timerProgress += playTick;
/*
      // ステージクリアの回数を満たしたら次ステージへ
      if (GameScoring.correct >= clearThreshould) {
        //GameScoring.signal = GameSignal.clear;
        //GameScoring.stageIndex++;
        //GameScoring.bonus += ((1.0 - timerProgress) * 1000).ceil();
        //GameScoring.addBonus();
        // ステージクリア回数がステージ配列の最後に到達したらゲームオーバー
        if (GameScoring.stageIndex >= GameScoring.gameLevels.length) {
          overlays.add('GameOver');
        }
      }
*/

      if (GameScoring.timerProgress >= 1.0) {
        FlameAudio.bgm.stop();
        topQuestionCaption = "Time up!!";
        topQuestionText.text = topQuestionCaption;
        progressTimeComponent.timer.stop();
        remove(progressTimeComponent);
        GameScoring.signal = GameSignal.timeup;
        FlameAudio.play('sfx/failed.mp3');

        // ステージクリア数が満たないときはタイムアップでゲームオーバー
        if (GameScoring.correct <= clearThreshould) {
          overlays.add('GameOver');
        }
      }
    }
  }

  // ゲーム開始
  void go() {
    GameScoring.makeQuestion();
    GameScoring.signal = GameSignal.playing;
    FlameAudio.bgm.stop();
    FlameAudio.play('sfx/question.mp3');
    FlameAudio.bgm.play('bgm/csikos.mp3', volume: 0.2);

    progressTimeComponent = TimerComponent(
      period: gameFPS, // 120hz
      repeat: true,
      autoStart: true,
      removeOnFinish: true,
      onTick: () => {
        updateTimerBar(),
      },
    );
    add(progressTimeComponent);

    topQuestionCaption = GameScoring.question["TopCaption"];
    midQuestionCaption = GameScoring.question["MidCaption"];
    bottomQuestionCaption = GameScoring.question["BottomCaption"];
    countdownTimeComponent.removeFromParent();
  }

  // 次のクイズを作成
  void nextQuestion() {
    // 1秒後のタイマー後に出題
    final nextTimeComponent = TimerComponent(
      period: 0.8,
      repeat: false,
      autoStart: true,
      removeOnFinish: true,
      onTick: () => {
        FlameAudio.play('sfx/question.mp3'),
        //GameScoring.question = currentQuestion,
        changeQuestionTextColor(),
        GameScoring.makeQuestion(),
        topQuestionCaption = GameScoring.question["TopCaption"],
        midQuestionCaption = GameScoring.question["MidCaption"],
        bottomQuestionCaption = GameScoring.question["BottomCaption"],
        //currentQuestion['Result'] = null,
        logger.d('${GameScoring.question}'),

        midQuestionText.add(ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: fadeInSpeed),
        )),
        bottomQuestionText.add(ScaleEffect.to(
          Vector2.all(1.0),
          EffectController(duration: fadeInSpeed),
        )),
      },
    );
    add(nextTimeComponent);
  }

  // クイズの表示
  void makeQuestionText() {
    final defaultStyle = TextStyle(
        fontSize: questionTextHeight,
        color: BasicPalette.white.color,
        fontFamily: 'PixelMplus');

    final defaultPaint = TextPaint(style: defaultStyle);
    topQuestionText = TextComponent(
        text: topQuestionCaption, textRenderer: defaultPaint)
      ..anchor = Anchor.center
      ..x = 0
      ..y =
          -(gameScreenHeight / 2) + screenTopOffset - (questionTextHeight * 3);

    midQuestionText = TextComponent(
        text: midQuestionCaption, textRenderer: defaultPaint)
      ..anchor = Anchor.center
      ..x = 0
      ..y =
          -(gameScreenHeight / 2) + screenTopOffset - (questionTextHeight * 2);

    bottomQuestionText = TextComponent(
        text: bottomQuestionCaption, textRenderer: defaultPaint)
      ..anchor = Anchor.center
      ..x = 0
      ..y = -(gameScreenHeight / 2) + screenTopOffset - (questionTextHeight);

/*
    topQuestionText =
        TextComponent(text: topQuestionCaption, textRenderer: defaultPaint)
          ..anchor = Anchor.center
          ..x = gameScreenWidth + (timerbarWidth / 2)
          ..y = timerHeightOffset + textSpaceingHeight + questionTextHeight;

    midQuestionText = TextComponent(
        text: midQuestionCaption, textRenderer: defaultPaint)
      ..anchor = Anchor.center
      ..x = gameScreenWidth + (timerbarWidth / 2)
      ..y = timerHeightOffset + textSpaceingHeight + (questionTextHeight * 2);

    bottomQuestionText = TextComponent(
        text: bottomQuestionCaption, textRenderer: defaultPaint)
      ..anchor = Anchor.center
      ..x = gameScreenWidth + (timerbarWidth / 2)
      ..y = timerHeightOffset + textSpaceingHeight + (questionTextHeight * 3);

    //addAll([topQuestionText, midQuestionText, bottomQuestionText]);
*/
    world.addAll([topQuestionText, midQuestionText, bottomQuestionText]);
  }

  // ゲームレベルによって使う色を増やす
  void changeQuestionTextColor() {
    final defaultStyle = TextStyle(
        fontSize: questionTextHeight,
        color: BasicPalette.white.color,
        fontFamily: 'PixelMplus');

    const redStyle = TextStyle(
        fontSize: questionTextHeight,
        color: Colors.red,
        fontFamily: 'PixelMplus');

    const blueStyle = TextStyle(
        fontSize: questionTextHeight,
        color: Colors.blue,
        fontFamily: 'PixelMplus');

    const greenStyle = TextStyle(
        fontSize: questionTextHeight,
        color: Colors.green,
        fontFamily: 'PixelMplus');

    final defaultPaint = TextPaint(style: defaultStyle);
    final redPaint = TextPaint(style: redStyle);
    final bluePaint = TextPaint(style: blueStyle);
    final greenPaint = TextPaint(style: greenStyle);

    List<TextPaint> renderers = [defaultPaint, redPaint, bluePaint, greenPaint];
//    int topColorIndex = random.nextInt(renderers.length);
    int midColorIndex = random.nextInt(renderers.length);
    int bottomColorIndex = random.nextInt(renderers.length);

    topQuestionText.textRenderer = defaultPaint;
    if (GameScoring.level == GameLevel.easy) {
      midQuestionText.textRenderer = defaultPaint;
      bottomQuestionText.textRenderer = defaultPaint;
    } else if (GameScoring.level == GameLevel.normal) {
      midQuestionText.textRenderer = defaultPaint;
      bottomQuestionText.textRenderer = renderers[bottomColorIndex];
    } else if (GameScoring.level == GameLevel.hard) {
      midQuestionText.textRenderer = renderers[midColorIndex];
      bottomQuestionText.textRenderer = renderers[bottomColorIndex];
    }
  }

  // ニューゲームの初期化
  void restart() {
    GameScoring.signal = GameSignal.title;
    GameScoring.stageIndex = 0;
    GameScoring.bonus = 0;
    GameScoring.score = 0;
    GameScoring.mistake = 0;
    GameScoring.correct = 0;
    GameScoring.timerProgress = 0.0;
    GameScoring.level = GameLevel.easy;
    GameScoring.rule = GameRule.nothing;
    GameScoring.reds = [];
    GameScoring.greens = [];
    GameScoring.blues = [];
    GameScoring.all = [];
    //GameScoring.pieces = [];
    changeQuestionTextColor();

    topQuestionCaption = "";
    midQuestionCaption = "";
    bottomQuestionCaption = "";
    countdownCaption = "";

    midQuestionText.add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: fadeInSpeed),
    ));
    bottomQuestionText.add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: fadeInSpeed),
    ));

    timerBar.progress = GameScoring.timerProgress;
    removeGameComponents();
    overlays.add('MainMenu');
  }

  // ステージクリアの初期化処理
  void resetStage() {
    // restartと処理を共通化する
    topQuestionCaption = "";
    midQuestionCaption = "";
    bottomQuestionCaption = "";
    countdownCaption = "";

    GameScoring.timerProgress = 0.0;
    timerBar.progress = GameScoring.timerProgress;
    GameScoring.correct = 0;
    GameScoring.bonus = 0;
    GameScoring.signal = GameSignal.ready;
  }

  // クイズのラベルを隠す
  void hideQuestion() {
    midQuestionText.add(ScaleEffect.to(
      Vector2.all(0.0),
      EffectController(duration: fadeOutSpeed),
    ));
    bottomQuestionText.add(ScaleEffect.to(
      Vector2.all(0.0),
      EffectController(duration: fadeOutSpeed),
    ));
  }

  void showQuestion() {
    midQuestionText.add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: fadeInSpeed),
    ));
    bottomQuestionText.add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: fadeInSpeed),
    ));
  }

  void showGameOverMenu() {
    // ゲームオーバーのメニュー表示
    topQuestionCaption = "THEY LIVE WE SLEEP";
    // 表示を隠してスコア表示
    GameScoring.signal = GameSignal.over;
    overlays.add('GameOver');
  }
}
