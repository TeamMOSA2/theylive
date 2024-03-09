const double gameScreenWidth = 400.0; // 盤面の実サイズ幅
const double gameScreenHeight = 950.0; // 盤面の実サイズ高さ
const double questionTextHeight = 22.0; // クイズの出題文字の高さ
const double meterHeight = 20.0; // タイマーメーターの高さ
const double fadeInSpeed = 0.05; // クイズの出題文字の表示速度
const double fadeOutSpeed = 0.05; // クイズの出題文字の消える速度
const double gameFPS = 1.0 / 120; // 1フレームの処理時間(秒)
const double playTick = 1.0 / (120 * 10); // 1ステージの時間(9秒)
//const double playTick = 1.0 / (120 * 90); // テスト用1ステージの時間(90秒)
//const double playTick = 1.0 / (120 * 360); // テスト用1ステージの時間(360秒)
const int clearThreshould = 3; // ステージクリアの回答数
const double timerHeightOffset = 50.0; // タイマーのY座標表示位置
const double quotaHeightOffset = 10.0; // クリア閾値のY座標表示位置
const double textSpaceingHeight = 8.0; // テキスト間の余白
const double timerbarWidth = 400.0; // 残り時間ゲージの幅

// メニューのフォントサイズ
const double menuTitleFontHeight = 24.0;
const double menuButtonFontHeight = 24.0;
const double menuDescriptionFontHeight = 20.0;

// メニューのダイアログサイズ
const double menuDialogWidth = 400.0;
const double menuDialogHeight = 300.0;

const double space = 22; // グリッドの最小単位
const int logicalBlockSize =
    6; // 倫理ブロックサイズ。space * logicalBlockSizeが論理ブロックの一辺になる
// gameScreenWidth:500, gameScreenHeight:1000の時
// 論理ブロックx [0]:-250...-125 [1]:-125...0 [2]:0...125 [3]:125...250
// 論理ブロックy [0]:250...125 [1]:125...0 [2]:0...-125 [3]:-125...-250

const double smallBlock = space * 3;
const double mediumBlock = space * 5;
const double largeBlock = space * 8;

const int gamePiecesRetryCountMax = 6; // 駒構築の再試行回数
const int gamePiecesMax = 30; // 画面内の最大コマ数
final int largePieceMax = (gamePiecesMax / 10).floor();
final int mediumPieceMax = (gamePiecesMax / 3).floor();

// ゲージ、メッセージの表示領域の高さ
const double screenTopOffset = 130;
// 画面左端の補正
const double screenWidthOffset = 0;
//const double screenWidthOffset = 0;
const double blockPadding = space; // ブロック間のパディング

// ステージのレベル
enum GameLevel {
  easy(0),
  normal(1),
  hard(2);

  final int level;
  const GameLevel(this.level);
}

enum GameSignal {
  title(0),
  ready(1), // 開始前カウントダウン
  playing(2), // プレイ中
  pause(3), // ポーズ
  timeup(4), // 終了
  clear(5), // ステージクリア
  over(6); // ゲーム終了

  final int signal;
  const GameSignal(this.signal);
}

// ゲームで使われる色のルール
enum ColorRule {
  anyColor(0), // なんでもおk
  red(1), // 駒の背景色限定
  green(2), // 駒の背景色限定
  blue(3), // 駒の背景色限定
  white(4), // 駒の文字色限定
  black(5); // 駒の文字色限定

  final int colorID;
  const ColorRule(this.colorID);
}

// ゲームのルールID
enum GameRule {
  // 任意の色を選択するルールは色未指定も含む
  nothing(0), // ルールみ設定
  minimum(1), // 任意の色の最小値
  maximum(2), // 任意の色の最大値
  previous(3), // nより小さい次の数　Next number less than 10
  next(4), // nより大きい次の数 Next number greater than 10
  primeNumber(5), // 素数
  notPrimeNumber(6), // 素数じゃない
  minPrimeNumber(7), // 素数の最小
  maxPrimeNumber(8); // 素数の最大

//  even(3), // 任意の色の偶数
//  odd(4),
//  match(5), // 一致する数字
//  multiplier(6), // 2のn乗
//  primeNumber(7), // 素数
//  notPrimeNumber(8), // 素数じゃない
//  fibonacci(9); //フィボナッチ数

  final int ruleID;
  const GameRule(this.ruleID);
}

// 100までの素数
const Set<int> primeNumbers = {
  2,
  3,
  5,
  7,
  11,
  13,
  17,
  19,
  23,
  29,
  31,
  37,
  41,
  43,
  47,
  53,
  59,
  61,
  67,
  71,
  73,
  79,
  83,
  89,
  97
};
