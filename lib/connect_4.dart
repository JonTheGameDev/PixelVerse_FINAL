import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'dart:async';
import 'package:connect_4/connect4_components/level.dart';
import 'package:connect_4/connect4_components/offline_level.dart';
class Connect4 extends FlameGame with HasKeyboardHandlerComponents,TapCallbacks{
  String mode;
  Connect4({required this.mode});
  late final CameraComponent cam;
  @override
  late final world;
  @override
  FutureOr<void> onLoad() async{
    await images.loadAllImages();
    world = (mode=="online")?Level():OfflineLevel();
    cam=CameraComponent.withFixedResolution(world: world,width: 480, height: 360);
    cam.viewfinder.anchor=Anchor.topLeft;
    addAll([cam,world]);
    return super.onLoad();
  }
}
