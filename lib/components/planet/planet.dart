import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:planetriod/model/custom_hitbox_entity.dart';
import 'package:planetriod/planetroid_game.dart';

enum PlanetState { idle }

//SpriteAnimationGroupComponent for Animations
class Planet extends SpriteComponent
    with HasGameRef<PlanetroidGame>, KeyboardHandler, CollisionCallbacks {
  Planet({
    super.position,
    super.size,
    this.planetName = "planet_1",
  });
  final String planetName;
  CustomHitBoxEntity customHitBoxEntity =
      CustomHitBoxEntity(offSetX: 3, offSetY: 3, width: 75, height: 75);
  double moveSpeed = 100;

  double rotationSpeed = 1.0;
  double currentRotation = 0.0;

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

  @override
  FutureOr<void> onLoad() {
    // Adjust position to center the object
    sprite = Sprite(
      game.images.fromCache("planets/$planetName.png"),
    );
    add(CircleHitbox(
      position: Vector2(customHitBoxEntity.offSetX, customHitBoxEntity.offSetY),
      radius: 45,
    ));
    anchor = Anchor.center;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    updateRotation(dt);
  }
}
