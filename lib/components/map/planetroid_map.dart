import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:planetriod/components/planet/planet.dart';
import 'package:planetriod/components/rocket/rocket.dart';
import 'package:planetriod/components/space/space_background.dart';
import 'package:planetriod/planetroid_game.dart';

class PlanetroidMap extends World with HasGameRef<PlanetroidGame> {
  late TiledComponent map;
  late Planet planet;
  double planetGravity = 100;
  final String level;
  Vector2 mapSize = Vector2(800, 600);
  PlanetroidMap({required this.level});

  void spawingObjects() {
    final spawnPointsLayer = map.tileMap.getLayer<ObjectGroup>("Spawnpoints");
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Planet':
            planet = Planet(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
              planetName: "planet_36",
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
          default:
        }
      }
    }
  }

  // void addCollisions() {
  //   final collisionsLayer = map.tileMap.getLayer<ObjectGroup>('Collisions');
  //   if (collisionsLayer != null) {
  //     for (final collision in collisionsLayer.objects) {
  //       switch (collision.class_) {
  //         case 'Platform':
  //           final platform = CollisionsBlock(
  //             position: Vector2(collision.x, collision.y),
  //             size: Vector2(collision.width, collision.height),
  //             isPlatform: true,
  //           );
  //           collisionBlockList.add(platform);
  //           add(platform);
  //           break;
  //         default:
  //           final block = CollisionsBlock(
  //             position: Vector2(collision.x, collision.y),
  //             size: Vector2(collision.width, collision.height),
  //           );
  //           collisionBlockList.add(block);
  //           add(block);
  //       }
  //     }
  //   }
  //   player.collisionBlockList = collisionBlockList;
  // }

  @override
  Future<void> onLoad() async {
    map = await TiledComponent.load(level, Vector2.all(16));
    add(map);
    spawingObjects();
    // addCollisions();

    return super.onLoad();
  }
}
