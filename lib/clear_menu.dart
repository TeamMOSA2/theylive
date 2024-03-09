import 'game_scoring.dart';
import 'package:flutter/material.dart';

import 'my_game.dart';
import 'game_const.dart';

class ClearMenu extends StatelessWidget {
  // Reference to parent game.
  final MyGame game;

  const ClearMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

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
                'Clear bonus! ${GameScoring.bonus}',
                style: const TextStyle(
                  color: whiteTextColor,
                  fontSize: menuTitleFontHeight,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('ClearMenu');
                    game.generateGameComponents();
                    game.prepareNextStage();
                    game.startup();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: menuButtonFontHeight,
                      color: blackTextColor,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
