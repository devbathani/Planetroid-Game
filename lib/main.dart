import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:planetriod/planetroid_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  PlanetroidGame game = PlanetroidGame();
  runApp(
    MaterialApp(
      home: GameWidget(
        game: kDebugMode ? PlanetroidGame() : game,
      ),
    ),
  );
}
