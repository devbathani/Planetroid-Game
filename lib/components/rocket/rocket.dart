import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:planetriod/components/planet/planet.dart';
import 'package:planetriod/model/custom_hitbox_entity.dart';
import 'package:planetriod/planetroid_game.dart';

enum RocketState { up, left, right, down, hit }

class Rocket extends SpriteAnimationGroupComponent
    with HasGameRef<PlanetroidGame>, KeyboardHandler, CollisionCallbacks {
  late Vector2 velocity;
  late Vector2 mapSize;
  late double thrust;
  bool gotHit = false;
  late double maxSpeed;
  Planet planet;
  final double planetGravity;
  CustomHitBoxEntity customHitBoxEntity =
      CustomHitBoxEntity(offSetX: 0, offSetY: 0, width: 20, height: 20);
  late final SpriteAnimation upAnimation;
  late final SpriteAnimation downAnimation;
  late final SpriteAnimation leftAnimation;
  late final SpriteAnimation rightAnimation;
  late final SpriteAnimation hitAnimation;

  String baseImagePath = "hit_animation";
  Vector2 startingPosition = Vector2.zero();
  List<Sprite> hitSprites = [];

  Rocket(
    Vector2 position,
    this.velocity,
    this.planet,
    this.planetGravity,
    this.mapSize,
  ) : super(position: position, size: Vector2.all(32)) {
    thrust = 100.0;
    maxSpeed = 200.0;
  }
  SpriteAnimation spritAnimation(String name, int amount, double vectorSize) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(name),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.05,
        textureSize: Vector2.all(vectorSize),
      ),
    );
  }

  void initializeAnimation() {
    upAnimation = spritAnimation("rocket_up.png", 1, 64);
    downAnimation = spritAnimation("rocket_down.png", 1, 64);
    rightAnimation = spritAnimation("rocket_right.png", 1, 64);
    leftAnimation = spritAnimation("rocket_left.png", 1, 64);
    // Load each frame of the hit animation
    for (int i = 1; i <= 20; i++) {
      hitSprites.add(Sprite(game.images.fromCache("explosions/000$i.png")));
    }
    hitAnimation = SpriteAnimation.spriteList(hitSprites, stepTime: 0.05);
    animations = {
      RocketState.up: upAnimation,
      RocketState.down: downAnimation,
      RocketState.right: rightAnimation,
      RocketState.left: leftAnimation,
      RocketState.hit: hitAnimation,
    };
    current = RocketState.right;
  }

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(
      position: Vector2(customHitBoxEntity.offSetX, customHitBoxEntity.offSetY),
      size: Vector2(customHitBoxEntity.width, customHitBoxEntity.height),
      collisionType: CollisionType.passive,
    ));
    initializeAnimation();
    priority = 1;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gotHit) {
      // Apply gravity towards the planet
      final direction = (planet.position - position).normalized();
      velocity += direction * planetGravity * dt;

      // Clamp velocity magnitude
      velocity.clampLength(0, maxSpeed);

      // Update position based on velocity
      position += velocity * dt;

      // Wrap around the map if the rocket goes out of bounds
      if (position.x < 0) {
        position.x += mapSize.x;
      } else if (position.x > mapSize.x) {
        position.x -= mapSize.x;
      }
      if (position.y < 0) {
        position.y += mapSize.y;
      } else if (position.y > mapSize.y) {
        position.y -= mapSize.y;
      }
    }
  }

  void reSpawn() {
    if (game.playSound) {
      FlameAudio.play("hit.mp3");
    }
    const hitDuration = Duration(seconds: 3);
    const appearingDuration = Duration(milliseconds: 350);
    const canMoveDuration = Duration(milliseconds: 400);
    gotHit = true;
    current = RocketState.hit;
    Future.delayed(hitDuration, () {
      scale.x = 1;
      position = startingPosition - Vector2.all(32);
      Future.delayed(appearingDuration, () {
        velocity = Vector2.zero();
        position = startingPosition;
        current = RocketState.right;
        Future.delayed(canMoveDuration, () => gotHit = false);
      }); // Future.delayed
    }); // Future.delayed
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!gotHit) {
      if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
        velocity.y -= thrust;
        current = RocketState.up;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
        velocity.x -= thrust;
        current = RocketState.left;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
        velocity.y += thrust;
        current = RocketState.down;
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
        velocity.x += thrust;
        current = RocketState.right;
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Planet) reSpawn();
    super.onCollisionStart(intersectionPoints, other);
  }
}
