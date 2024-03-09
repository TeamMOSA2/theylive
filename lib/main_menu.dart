import 'package:flutter/material.dart';

import 'my_game.dart';
import 'game_const.dart';

class MainMenu extends StatelessWidget {
  // Reference to parent game.
  final MyGame game;

  const MainMenu({super.key, required this.game});

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
              const Text(
                'They live',
                style: TextStyle(
                    color: whiteTextColor,
                    fontSize: menuTitleFontHeight,
                    fontFamily: 'PixelMplus'),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('MainMenu');
                    game.generateGameComponents();
                    game.startup();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Play',
                    style: TextStyle(
                        fontSize: menuButtonFontHeight,
                        color: blackTextColor,
                        fontFamily: 'PixelMplus'),
                  ),
                ),
              ),
              const SizedBox(height: menuDescriptionFontHeight),
              const Text(
                'NO THOUGHT', // ランダムでいくつかのパターンを表示する
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: whiteTextColor,
                    fontSize: 16,
                    fontFamily: 'PixelMplus'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
