import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:planetriod/components/asteroids/asteroids.dart';
import 'package:planetriod/components/map/planetroid_map.dart';
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
      CustomHitBoxEntity(offSetX: 5, offSetY: 5, width: 13, height: 15);
  late final SpriteAnimation upAnimation;
  late final SpriteAnimation downAnimation;
  late final SpriteAnimation leftAnimation;
  late final SpriteAnimation rightAnimation;
  late final SpriteAnimation hitAnimation;
  PlanetroidMap planetroidMap = PlanetroidMap(level: "planetroid_01.tmx");
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
    maxSpeed = 300.0;
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

  void reSpawn() {
    if (game.playSound) {
      FlameAudio.play("hit.mp3", volume: 0.2);
    }
    const hitDuration = Duration(milliseconds: 350);
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
        planetroidMap.decreaseLife();
        Future.delayed(canMoveDuration, () => gotHit = false);
      }); // Future.delayed
    }); // Future.delayed
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

      final r = position.distanceTo(planet.position);
      print("radius : $r");
      final sinTheta = ((planet.position - position).x) / r;
      final cosTheta = ((planet.position - position).y) / r;
      final Vector2 gravity = Vector2(
          (planetGravity * sinTheta) / (pow(r, 1.7)),
          (planetGravity * cosTheta) / (pow(r, 1.7)));

      velocity += gravity * dt;
      print("velocity : $velocity");
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

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!gotHit) {
      if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
        velocity.y -= thrust;
        print("object");
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
    if (other is Asteroid) reSpawn();
    super.onCollisionStart(intersectionPoints, other);
  }
}
