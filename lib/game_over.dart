import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import 'my_game.dart';
import 'game_const.dart';
import 'game_scoring.dart';

class GameOver extends StatelessWidget {
  // Reference to parent game.
  final MyGame game;

  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);
    String clearCaption = 'GAME OVER';
    if (GameScoring.stageIndex >= GameScoring.gameLevels.length) {
      clearCaption = "Congratulations!";
      FlameAudio.bgm.stop();
      FlameAudio.play('sfx/nc214585.mp3');
    }

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: menuDialogHeight,
          width: menuDialogWidth,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                clearCaption,
                style: const TextStyle(
                  color: whiteTextColor,
                  fontSize: menuTitleFontHeight,
                  fontFamily: 'PixelMplus',
                ),
              ),
              const Text(
                "DO NOT QUESTION AUTHORITY",
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: menuTitleFontHeight,
                  fontFamily: 'PixelMplus',
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('GameOver');
                    game.restart();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: menuButtonFontHeight,
                      color: blackTextColor,
                      fontFamily: 'PixelMplus',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Score ${GameScoring.score}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: whiteTextColor,
                  fontSize: menuDescriptionFontHeight,
                  fontFamily: 'PixelMplus',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
