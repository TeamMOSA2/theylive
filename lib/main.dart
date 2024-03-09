import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'main_menu.dart';
import 'clear_menu.dart';
import 'game_over.dart';
import 'my_game.dart';

void main() {
  runApp(
    GameWidget<MyGame>.controlled(
      gameFactory: MyGame.new,
      overlayBuilderMap: {
        'MainMenu': (_, game) => MainMenu(game: game),
        'ClearMenu': (_, game) => ClearMenu(game: game),
        'GameOver': (_, game) => GameOver(game: game),
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}
