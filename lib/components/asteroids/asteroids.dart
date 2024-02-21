import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:planetriod/components/rocket/rocket.dart';
import 'package:planetriod/model/custom_hitbox_entity.dart';
import 'package:planetriod/planetroid_game.dart';

enum AsteroidState { idle, hit }

class Asteroid extends SpriteAnimationGroupComponent
    with HasGameRef<PlanetroidGame>, CollisionCallbacks {
  Asteroid({
    super.position,
    super.size,
  });
  late final SpriteAnimation idleAnimation;

  CustomHitBoxEntity customHitBoxEntity = CustomHitBoxEntity(
    offSetX: 20,
    offSetY: 20,
    width: 25,
    height: 25,
  );

  double rotationSpeed = 5.0;
  double currentRotation = 0.0;
  List<Sprite> hitSprites = [];

  void updateRotation(double dt) {
    // Calculate rotation increment based on rotation speed and delta time
    final double rotationIncrement = rotationSpeed * dt;

    // Update current rotation
    currentRotation += rotationIncrement;

    // Ensure rotation stays within 360 degrees
    currentRotation %= 360.0;

    // Apply rotation to the sprite
    angle = currentRotation;
  }

  SpriteAnimation spritAnimation(String name, int amount, double vectorSize) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(name),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.02,
        textureSize: Vector2.all(vectorSize),
      ),
    );
  }

  void initializeAsteroids() {
    idleAnimation = SpriteAnimation.spriteList(
      [
        Sprite(
          game.images.fromCache("asteroids/Asteroid 01 - Base.png"),
        ),
      ],
      stepTime: 0.05,
    );

    animations = {
      AsteroidState.idle: idleAnimation,
    };
    current = AsteroidState.idle;
  }

  @override
  FutureOr<void> onLoad() {
    priority = 1;
    initializeAsteroids();
    add(RectangleHitbox(
      position: Vector2(customHitBoxEntity.offSetX, customHitBoxEntity.offSetY),
      size: Vector2(customHitBoxEntity.width, customHitBoxEntity.height),
    ));

    anchor = Anchor.center;
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Rocket) {
      Future.delayed(const Duration(milliseconds: 350), () {
        removeFromParent();
      });
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    updateRotation(dt);
    super.update(dt);
  }
}
