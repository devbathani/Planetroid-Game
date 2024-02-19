import 'dart:async';

import 'package:flame/components.dart';
import 'package:planetriod/planetroid_game.dart';

class SpaceBackground extends SpriteComponent with HasGameRef<PlanetroidGame> {
  SpaceBackground({
    super.position,
    super.size,
  });
  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(
      game.images
          .fromCache("space/Purple Nebula/Purple_Nebula_01-1024x1024.png"),
    );
    return super.onLoad();
  }
}
