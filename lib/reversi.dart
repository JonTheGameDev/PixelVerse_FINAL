import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'dart:async';
import 'package:connect_4/reversi_components/reversiboard.dart';
class Reversi extends FlameGame with HasKeyboardHandlerComponents,TapCallbacks{
  late final CameraComponent cam;
  @override
  final world = Board();
  @override
  FutureOr<void> onLoad() async{
    await images.loadAllImages();
    cam=CameraComponent.withFixedResolution(world: world,width: 400, height: 400);
    cam.viewfinder.anchor=Anchor.topLeft;
    addAll([cam,world]);
    return super.onLoad();
  }
}
