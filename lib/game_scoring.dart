import 'dart:math';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'circle_rotator.dart';
import 'game_const.dart';
import 'circle_condition.dart';
import 'dart:math' as math;

// 採点用のクラス
class GameScoring {
  static List<CircleRotator> pieces = [];
  static List<int> reds = [];
  static List<int> greens = [];
  static List<int> blues = [];
  static List<int> all = [];
  static Map<String, dynamic> question = {};
  static GameSignal signal = GameSignal.title;
  static Random random = math.Random();
  static GameRule rule = GameRule.nothing; // 出題中のルール
  //await FlameAudio.createPool('correct_01.mp3', minPlayers: 1, maxPlayers: 1);
  static GameLevel level = GameLevel.easy; // 現在のゲーム何以後
  static List<GameLevel> gameLevels = [
    GameLevel.easy,
    GameLevel.normal,
    GameLevel.hard
  ]; // ステージ毎の難易度
  static int stageIndex = 0; // 現在のステージ
  static int score = 0;
  static int correct = 0; // 正解数
  static int mistake = 0;
  static int bonus = 0; // 残り時間ボーナス
  static double timerProgress = 0.0; // 1.0でゲーム終了

  static final logger = Logger();

  // 採点と作成済み駒の管理
  GameScoring();
  // 正解の判定
  // タップした駒のコンディションをあとでパラメータとして渡して数字と色を判定する
  static bool judgment(CircleCondition matchCondition) {
    // questionのルールに沿って採点
    bool result = false;
    if (question["Rule"] == GameRule.minimum) {
      result = scoringMinNumber(matchCondition);
    } else if (question["Rule"] == GameRule.maximum) {
      //return scoringMaxNumber(matchCondition);
      result = scoringMaxNumber(matchCondition);
    } else if (question["Rule"] == GameRule.next) {
      result = scoringNextNumber(matchCondition);
    } else if (question["Rule"] == GameRule.previous) {
      result = scoringPreviousNumber(matchCondition);
    } else if (question["Rule"] == GameRule.primeNumber) {
      result = scoringPrimeNumber(matchCondition);
    } else if (question["Rule"] == GameRule.notPrimeNumber) {
      result = scoringNotPrimeNumber(matchCondition);
    } else if (question["Rule"] == GameRule.minPrimeNumber) {
      result = scoringMinPrimeNumber(matchCondition);
    } else if (question["Rule"] == GameRule.maxPrimeNumber) {
      result = scoringMaxPrimeNumber(matchCondition);
    }

    // 正解数の加算
    if (result == true) {
      FlameAudio.play('sfx/correct_01.mp3');
      addScore();
      question['Result'] = "Correct!!";
      correct++;
    } else {
      FlameAudio.play('sfx/wrong_01.mp3');
      subScore();
      mistake++;
    }

    logger.d("judgment: missing rules!!");
    // ステージクリア判定
    if (correct >= clearThreshould) {
      //FlameAudio.play('sfx/countdown-3.mp3');
      stageIndex++;
      bonus += ((1.0 - timerProgress) * 1000).ceil();
      addBonus();
      if (GameScoring.stageIndex < gameLevels.length) {
        level = gameLevels[GameScoring.stageIndex];
      }
      signal = GameSignal.clear;
      result = true;
    }

    // それ以外は全部失敗
    return result;
  }

  // 最小の素数
  static bool scoringMinPrimeNumber(CircleCondition matchCondition) {
    Set<int> allSet = all.toSet(); // 出題の配列をSetに変換
    final existPrimeNumbers = primeNumbers.intersection(allSet);
    final matchPrimeNumbers = existPrimeNumbers.toList();
    final minPrimeNumber = matchPrimeNumbers.reduce(min);

    if (matchCondition.number == minPrimeNumber) {
      return true;
    }

    return false;
  }

  // 最大の素数
  static bool scoringMaxPrimeNumber(CircleCondition matchCondition) {
    Set<int> allSet = all.toSet(); // 出題の配列をSetに変換
    final existPrimeNumbers = primeNumbers.intersection(allSet);
    final matchPrimeNumbers = existPrimeNumbers.toList();
    final maxPrimeNumber = matchPrimeNumbers.reduce(max);
    //var maxValue = matchPrimeNumbers.isEmpty ? 0 : matchPrimeNumbers.reduce(max);

    if (matchCondition.number == maxPrimeNumber) {
      return true;
    }

    return false;
  }

  // 素数の採点
  static bool scoringPrimeNumber(CircleCondition matchCondition) {
    final isPrime = primeNumbers.contains(matchCondition.number);
    final isExist = all.contains(matchCondition.number);
    if (isExist == true && isPrime == true) {
      return true;
    }

    return false;
  }

  // 素数じゃない採点
  static bool scoringNotPrimeNumber(CircleCondition matchCondition) {
    final isPrime = primeNumbers.contains(matchCondition.number);
    final isExist = all.contains(matchCondition.number);
    if (isExist == true && isPrime == false) {
      return true;
    }

    return false;
  }

  // 次の数字の採点
  static bool scoringNextNumber(CircleCondition matchCondition) {
    ColorRule colorRule = question["Color"];
    // Ruleの中のNumberを探索して+1の配列の値とマッチすれば正解
    var result = -1;
    if (colorRule == ColorRule.anyColor) {
      result = all.firstWhere((element) => element > question['Number']);
    } else if (colorRule == ColorRule.red) {
      result = reds.firstWhere((element) => element > question['Number']);
    } else if (colorRule == ColorRule.green) {
      result = greens.firstWhere((element) => element > question['Number']);
    } else if (colorRule == ColorRule.blue) {
      result = blues.firstWhere((element) => element > question['Number']);
    }
    logger.d(
        "scoringNextNumber result: $result , tap number: ${matchCondition.number}");
    if (result == matchCondition.number) {
      logger.d("  MATCH!!");
      return true;
    }
    logger.d("  UNMATCH!!");

    return false;
  }

  // 前の数字の採点
  static bool scoringPreviousNumber(CircleCondition matchCondition) {
    ColorRule colorRule = question["Color"];
    // Ruleの中のNumberを探索して+1の配列の値とマッチすれば正解
    var result = -1;
    if (colorRule == ColorRule.anyColor) {
      result = all.lastWhere((element) => element < question['Number']);
    } else if (colorRule == ColorRule.red) {
      result = reds.lastWhere((element) => element < question['Number']);
    } else if (colorRule == ColorRule.green) {
      result = greens.lastWhere((element) => element < question['Number']);
    } else if (colorRule == ColorRule.blue) {
      result = blues.lastWhere((element) => element < question['Number']);
    }
    logger.d(
        "scoringNextNumber result: $result , tap number: ${matchCondition.number}");
    if (result == matchCondition.number) {
      logger.d("  MATCH!!");
      return true;
    }
    logger.d("  UNMATCH!!");

    return false;
  }

  // minの採点
  static bool scoringMinNumber(CircleCondition matchCondition) {
    ColorRule colorRule = question["Color"];
    // allNumbersの最小値で判定
    if (colorRule == ColorRule.anyColor) {
      if (matchCondition.number == all[0]) {
        return true;
      }
    } else if (colorRule == ColorRule.red) {
      if (matchCondition.color == Colors.red &&
          matchCondition.number == reds[0]) {
        return true;
      }
    } else if (colorRule == ColorRule.green) {
      if (matchCondition.color == Colors.green &&
          matchCondition.number == greens[0]) {
        return true;
      }
    } else if (colorRule == ColorRule.blue) {
      if (matchCondition.color == Colors.blue &&
          matchCondition.number == blues[0]) {
        return true;
      }
    }

    return false;
  }

  // maxの採点
  static bool scoringMaxNumber(CircleCondition matchCondition) {
    ColorRule colorRule = question["Color"];
    // allNumbersの最小値で判定
    if (colorRule == ColorRule.anyColor) {
      if (matchCondition.number == all.reduce(max)) {
        return true;
      }
    } else if (colorRule == ColorRule.red) {
      if (matchCondition.color == Colors.red &&
          matchCondition.number == reds.reduce(max)) {
        return true;
      }
    } else if (colorRule == ColorRule.green) {
      if (matchCondition.color == Colors.green &&
          matchCondition.number == greens.reduce(max)) {
        return true;
      }
    } else if (colorRule == ColorRule.blue) {
      if (matchCondition.color == Colors.blue &&
          matchCondition.number == blues.reduce(max)) {
        return true;
      }
    }
    return false;
  }

  // hardレベルは最小、最大値、素数、素数の最大最小の出題
  static Map<String, dynamic> makeHardQuestion() {
    Map<String, dynamic> newQuestion;
    int ruleIndex = random.nextInt(5);
    // 1/3の確率で素数問題
    if (ruleIndex % 4 == 0) {
      newQuestion = makeMinOrMaxPrimeNumberQuestion();
      // 1/3の確率で最小最大問題
    } else if (ruleIndex % 4 == 1) {
      newQuestion = makePreviousOrNextNumberQuestion();
    } else if (ruleIndex % 4 == 2) {
      newQuestion = makeMinOrMaxNumberQuestion();
    } else {
      newQuestion = makePrimeNumberQuestion();
    }
    return newQuestion;
  }

  // normalレベルは最小、最大値、素数の出題
  static Map<String, dynamic> makeNormalQuestion() {
    Map<String, dynamic> newQuestion;
    int ruleIndex = random.nextInt(4);
    // 1/3の確率で素数問題
    if (ruleIndex % 3 == 0) {
      newQuestion = makePrimeNumberQuestion();
      // 1/3の確率で最小最大問題
    } else if (ruleIndex % 3 == 1) {
      newQuestion = makeMinOrMaxNumberQuestion();
    } else {
      newQuestion = makePreviousOrNextNumberQuestion();
    }
    return newQuestion;
  }

  // easyレベルは最小、最大値、素数の出題
  static Map<String, dynamic> makeEasyQuestion() {
    Map<String, dynamic> newQuestion;
    //newQuestion = makePrimeNumberQuestion();
    int ruleIndex = random.nextInt(3);
    // 1/3の確率で素数問題
    if (ruleIndex == 0) {
      newQuestion = makePrimeNumberQuestion();
      // 2/3の確率で最小最大問題
    } else {
      newQuestion = makeMinOrMaxNumberQuestion();
    }
    return newQuestion;
  }

  // 出題の作成
  static Map<String, dynamic> makeQuestion() {
    if (level == GameLevel.easy) {
      question = makeEasyQuestion();
    } else if (level == GameLevel.normal) {
      question = makeNormalQuestion();
    } else if (level == GameLevel.hard) {
      question = makeHardQuestion();
    }
    return question;
  }

  // 最小、最大の素数
  static Map<String, dynamic> makeMinOrMaxPrimeNumberQuestion() {
    //final colors = ["Any",];
    final colorRules = [
      ColorRule.anyColor,
    ];
    List<GameRule> ruleIDs = [
      GameRule.minPrimeNumber,
      GameRule.maxPrimeNumber,
      GameRule.notPrimeNumber
    ];
    int ruleIndex = 0;
    int colorIndex = 0;
    // 全部の配列が0件になったらコンプリート処理を入れる

    Set<int> allSet = all.toSet(); // 出題の配列をSetに変換
    bool isExit = false;
    // 素数、素数じゃない出題の答えがない時は逆の出題にする
    do {
      ruleIndex = random.nextInt(ruleIDs.length); // 最小の素数 or 最大の素数
      if (ruleIDs[ruleIndex] == GameRule.minPrimeNumber ||
          ruleIDs[ruleIndex] == GameRule.maxPrimeNumber) {
        final existPrimeNumbers = primeNumbers.intersection(allSet);
        isExit = existPrimeNumbers.isNotEmpty; // 集合の合致が一件でもあるなら素数あり
        logger.d("existPrimeNumbers: $existPrimeNumbers");
      } else if (ruleIDs[ruleIndex] == GameRule.notPrimeNumber) {
        final existPrimeNumbers = primeNumbers.intersection(allSet);
        isExit = existPrimeNumbers.isEmpty; // 集合の合致がなければ素数なし
        logger.d("existPrimeNumbers: $existPrimeNumbers");
      }
    } while (isExit != true);

    final midMessages = [
      "",
      "",
    ];
    final bottomMessages = [
      "Tap min prime number",
      "Tap max prime number",
    ];

    // 回答用に答えを保存
    Map<String, dynamic> question = {
      "TopCaption": "",
      "MidCaption": midMessages[ruleIndex],
      "BottomCaption": bottomMessages[ruleIndex],
      "Rule": ruleIDs[ruleIndex],
      "Color": colorRules[colorIndex],
      "Result": null,
    };
    rule = ruleIDs[ruleIndex];

    return question;
  }

  // 素数、素数じゃない
  static Map<String, dynamic> makePrimeNumberQuestion() {
    //final colors = ["Any"];
    final colorRules = [
      ColorRule.anyColor,
    ];
    //final colorArrays = [all];
    List<GameRule> ruleIDs = [GameRule.primeNumber, GameRule.notPrimeNumber];
    int ruleIndex = 0;
    int colorIndex = 0;

    Set<int> allSet = all.toSet(); // 出題の配列をSetに変換
    bool isExit = false;
    // 素数、素数じゃない出題の答えがない時は逆の出題にする
    do {
      ruleIndex = random.nextInt(ruleIDs.length); // 素数 or 素数じゃない
      if (ruleIDs[ruleIndex] == GameRule.primeNumber) {
        final existPrimeNumbers = primeNumbers.intersection(allSet);
        isExit = existPrimeNumbers.isNotEmpty; // 集合の合致が一件でもあるなら素数あり
        logger.d("existPrimeNumbers: $existPrimeNumbers");
      } else if (ruleIDs[ruleIndex] == GameRule.notPrimeNumber) {
        final existNotPrimeNumbers = allSet.difference(primeNumbers);
        isExit = existNotPrimeNumbers.isNotEmpty; // 集合の合致がなければ素数なし
        logger.d("existPrimeNumbers: $existNotPrimeNumbers");
      }
    } while (isExit != true);

    //colorIndex = 0; // ルールのチェックが終わるまで全色固定
    //int ruleIndex = random.nextInt(2);
    //final colorStr = colors[colorIndex];
    final midMessages = [
      "",
      "",
    ];
    final bottomMessages = [
      "Tap prime number",
      "Tap not prime number",
    ];

    // 回答用に答えを保存
    Map<String, dynamic> question = {
      "TopCaption": "",
      "MidCaption": midMessages[ruleIndex],
      "BottomCaption": bottomMessages[ruleIndex],
      "Rule": ruleIDs[ruleIndex],
      "Color": colorRules[colorIndex],
      "Result": null,
    };
    rule = ruleIDs[ruleIndex];

    return question;
  }

  // nより小さい次の数、nより大きい次の数
  static Map<String, dynamic> makePreviousOrNextNumberQuestion() {
    final colors = ["Any", "Red", "Green", "Blue"];
    final colorRules = [
      ColorRule.anyColor,
      ColorRule.red,
      ColorRule.green,
      ColorRule.blue
    ];
    final colorArrays = [all, reds, greens, blues];
    List<GameRule> ruleIDs = [GameRule.previous, GameRule.next];
    // r,g,b(1〜3)のときは最低1個以上値があることを確認する。
    // なかったらcolorIndexは振り直す。
    int arrayRemain = 0;
    int ruleIndex = random.nextInt(ruleIDs.length);
    int colorIndex = 0;
    // 全部の配列が0件になったらコンプリート処理を入れる

    List<int> colorArray = [];
    do {
      colorIndex = random.nextInt(4);
      colorArray = colorArrays[colorIndex];
      arrayRemain = colorArray.length;
    } while (arrayRemain <= 0);

    int value = 0;
    if (ruleIDs[ruleIndex] == GameRule.previous) {
      // 色配列の数値1〜lengthを指定
      int lessIndex = random.nextInt(colorArray.length - 1) + 1;
      value = colorArray[lessIndex];
    } else if (ruleIDs[ruleIndex] == GameRule.next) {
      // 色配列の数値0〜length-1を指定
      int greaterIndex = random.nextInt(colorArray.length - 1);
      value = colorArray[greaterIndex];
    }

    //colorIndex = 0; // ルールのチェックが終わるまで全色固定
    //int ruleIndex = random.nextInt(2);
    final colorStr = colors[colorIndex];
    final topMessages = [
      "Tap next number",
      "Tap next number ",
    ];

    final midMessages = [
      "less than $value", // 色配列の数値1〜lengthを指定
      "greater than $value", // 色配列の数値0〜length-1を指定
    ];
    final bottomMessages = [
      "$colorStr color.",
      "$colorStr color.",
    ];

    // 回答用に答えを保存
    Map<String, dynamic> question = {
      "TopCaption": topMessages[ruleIndex],
      "MidCaption": midMessages[ruleIndex],
      "BottomCaption": bottomMessages[ruleIndex],
      "Rule": ruleIDs[ruleIndex],
      "Color": colorRules[colorIndex],
      "Number": value,
      "Result": null,
    };
    rule = ruleIDs[ruleIndex];

    return question;
  }

  static Map<String, dynamic> makeMinOrMaxNumberQuestion() {
    final colors = ["Any", "Red", "Green", "Blue"];
    final colorRules = [
      ColorRule.anyColor,
      ColorRule.red,
      ColorRule.green,
      ColorRule.blue
    ];
    final colorArrays = [all, reds, greens, blues];
    List<GameRule> ruleIDs = [GameRule.minimum, GameRule.maximum];
    // r,g,b(1〜3)のときは最低1個以上値があることを確認する。
    // なかったらcolorIndexは振り直す。
    int arrayRemain = 0;
    int ruleIndex = random.nextInt(ruleIDs.length);
    int colorIndex = 0;
    // 全部の配列が0件になったらコンプリート処理を入れる

    do {
      colorIndex = random.nextInt(4);
      List<int> colorArray = colorArrays[colorIndex];
      arrayRemain = colorArray.length;
    } while (arrayRemain <= 0);

    //int ruleIndex = random.nextInt(2);
    final colorStr = colors[colorIndex];
    final midMessages = [
      "Tap minimum number of",
      "Tap maximum number of",
    ];
    final bottomMessages = [
      "$colorStr color.",
      "$colorStr color.",
    ];

    // 回答用に答えを保存
    Map<String, dynamic> question = {
      "TopCaption": "",
      "MidCaption": midMessages[ruleIndex],
      "BottomCaption": bottomMessages[ruleIndex],
      "Rule": ruleIDs[ruleIndex],
      "Color": colorRules[colorIndex],
      "Result": null,
    };
    rule = ruleIDs[ruleIndex];

    return question;
  }

  // 出題範囲と駒の削除
  static removeNumber(CircleCondition condition, CircleRotator piece) {
    //currentScore.question[''];
    // 作成済みの駒から取り除く
    //List<CircleRotator> currentPieces = currentScore.pieces;
    final lists = [all, reds, blues, greens];

    // 全部の配列から対象の数値を削除する
    for (int i = 0; i < lists.length; i++) {
      lists[i].remove(condition.number);
    }

    // 正解の駒を管理配列から削除
    pieces.remove(piece);
    logger.d("remove: $condition.number");
  }

  // スコアの加算
  static addScore() {
    if (level == GameLevel.easy) {
      score += 100;
    } else if (level == GameLevel.normal) {
      score += 200;
    } else if (level == GameLevel.hard) {
      score += 400;
    }
  }

  // スコアの減算
  static subScore() {
    if (level == GameLevel.easy) {
      score -= 200;
    } else if (level == GameLevel.normal) {
      score -= 400;
    } else if (level == GameLevel.hard) {
      score -= 800;
    }
  }

  // タイムボーナスの加算
  static addBonus() {
    score += bonus;
  }
}
