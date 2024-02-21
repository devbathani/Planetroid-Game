import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:planetriod/components/asteroids/asteroids.dart';
import 'package:planetriod/components/heart/heart.dart';
import 'package:planetriod/components/planet/planet.dart';
import 'package:planetriod/components/rocket/rocket.dart';
import 'package:planetriod/components/space/space_background.dart';
import 'package:planetriod/planetroid_game.dart';

class PlanetroidMap extends World with HasGameRef<PlanetroidGame> {
  late TiledComponent map;
  late Planet planet;
  double planetGravity = 100;
  final String level;
  Vector2 mapSize = Vector2(700, 500);
  PlanetroidMap({required this.level});
  List<Heart> hearts = []; // List to hold all heart objects

  // Function to spawn hearts
  void spawnHeart(Vector2 position, Vector2 size) {
    final heart = Heart(
      position: position,
      size: size,
    );
    add(heart);
    hearts.add(heart); // Add heart to the list
  }

  void spawingObjects() {
    final spawnPointsLayer = map.tileMap.getLayer<ObjectGroup>("Spawnpoints");
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Planet':
            planet = Planet(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              planetName: "planet_143",
            );
            add(planet);
            break;
          case 'Space':
            final space = SpaceBackground(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );

            add(space);
            break;
          case 'Rocket':
            final rocket = Rocket(
              Vector2(spawnPoint.x, spawnPoint.y),
              Vector2(2, 2),
              planet,
              planetGravity,
              mapSize,
            );
            add(rocket);
            break;
          case 'Asteroid':
            final asteroid = Asteroid(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(asteroid);
            break;
          case 'Heart':
            spawnHeart(
              Vector2(spawnPoint.x, spawnPoint.y),
              Vector2(spawnPoint.width, spawnPoint.height),
            );
            break;

          default:
        }
      }
    }
  }

  @override
  Future<void> onLoad() async {
    map = await TiledComponent.load(level, Vector2.all(16));
    add(map);
    spawingObjects();
    // addCollisions();

    return super.onLoad();
  }
}
