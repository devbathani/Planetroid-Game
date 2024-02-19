import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:planetriod/components/planet/planet.dart';
import 'package:planetriod/planetroid_game.dart';

enum RocketState { up, left, right, down }

class Rocket extends SpriteAnimationGroupComponent
    with HasGameRef<PlanetroidGame>, KeyboardHandler {
  late Vector2 velocity;
  late double thrust;

  late double maxSpeed;
  Planet planet;
  final double planetGravity;

  late final SpriteAnimation upAnimation;
  late final SpriteAnimation downAnimation;
  late final SpriteAnimation leftAnimation;
  late final SpriteAnimation rightAnimation;

  Rocket(
    Vector2 position,
    this.velocity,
    this.planet,
    this.planetGravity,
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
    animations = {
      RocketState.up: upAnimation,
      RocketState.down: downAnimation,
      RocketState.right: rightAnimation,
      RocketState.left: leftAnimation,
    };
    current = RocketState.right;
  }

  @override
  FutureOr<void> onLoad() {
    initializeAnimation();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply gravity towards the planet
    final direction = (planet.position - position).normalized();
    velocity += direction * planetGravity * dt;

    // Clamp velocity magnitude
    velocity.clampLength(0, maxSpeed);

    // Update position based on velocity
    position += velocity * dt;
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
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
    return super.onKeyEvent(event, keysPressed);
  }
}
