import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:planetriod/components/map/planetroid_map.dart';

class PlanetroidGame extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  @override
  Color backgroundColor() => const Color(0xff211f30);
  late CameraComponent cameraComponent;
  late JoystickComponent joystickComponent;

  bool showControlls = false;
  bool playSound = false;
  List<String> levelNames = [
    "planetroid_01.tmx",
  ];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();

    loadLevel();
    return super.onLoad();
  }

  void loadLevel() async {
    await Future.delayed(const Duration(seconds: 1));

    PlanetroidMap worldMap =
        PlanetroidMap(level: levelNames[currentLevelIndex]);
    cameraComponent = CameraComponent.withFixedResolution(
      world: worldMap,
      height: 360,
      width: 640,
    );
    cameraComponent.viewfinder.anchor = Anchor.topLeft;
    addAll([cameraComponent, worldMap]);
  }
}
