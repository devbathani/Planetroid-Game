import 'dart:async';
import 'dart:developer';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:planetriod/planetroid_game.dart';

enum HeartState { one, two, three }

class Heart extends SpriteAnimationGroupComponent
    with HasGameRef<PlanetroidGame>, CollisionCallbacks {
  Heart({
    super.position,
    super.size,
  });
  late final SpriteAnimation oneAnimation;
  late final SpriteAnimation twoAnimation;
  late final SpriteAnimation threeAnimation;

  void initializeAsteroids() {
    oneAnimation = SpriteAnimation.spriteList(
      [
        Sprite(
          game.images.fromCache("numbers/01.png"),
        ),
      ],
      stepTime: 0.2,
    );
    twoAnimation = SpriteAnimation.spriteList(
      [
        Sprite(
          game.images.fromCache("numbers/02.png"),
        ),
      ],
      stepTime: 0.2,
    );
    threeAnimation = SpriteAnimation.spriteList(
      [
        Sprite(
          game.images.fromCache("numbers/03.png"),
        ),
      ],
      stepTime: 0.2,
    );

    animations = {
      HeartState.one: oneAnimation,
      HeartState.two: twoAnimation,
      HeartState.three: threeAnimation,
    };
    current = HeartState.three;
  }

  int lives = 3;

  void decreaseLife() {
    if (lives > 0) {
      // Decrease lives
      lives--;
      if (lives == 2) {
        current = HeartState.two;
      } else if (lives == 1) {
        current = HeartState.one;
      }
    } else {
      removeFromParent();
      log("Game over");
    }
  }

  @override
  FutureOr<void> onLoad() {
    priority = 1;
    initializeAsteroids();
    return super.onLoad();
  }
}
