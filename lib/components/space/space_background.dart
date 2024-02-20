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
    priority = -1;
    sprite = Sprite(
      game.images.fromCache("space/Starfields/Starfield_02-1024x1024.png"),
    );
    return super.onLoad();
  }
}
