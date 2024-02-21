import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:planetriod/planetroid_game.dart';

enum AsteroidState { idle, hit }

class Heart extends SpriteAnimationGroupComponent
    with HasGameRef<PlanetroidGame>, CollisionCallbacks {
  Heart({
    super.position,
    super.size,
  });
  late final SpriteAnimation idleAnimation;
  int lives = 3;

  void initializeAsteroids() {
    idleAnimation = SpriteAnimation.spriteList(
      [
        Sprite(
          game.images.fromCache("heart/Red 1.png"),
        ),
        Sprite(
          game.images.fromCache("heart/Red 2.png"),
        ),
      ],
      stepTime: 0.2,
    );

    animations = {
      AsteroidState.idle: idleAnimation,
    };
    current = AsteroidState.idle;
  }

  void decreaseLife() {
    lives--;
  }

  @override
  FutureOr<void> onLoad() {
    priority = 1;
    initializeAsteroids();

    return super.onLoad();
  }
}
