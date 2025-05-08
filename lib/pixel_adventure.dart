import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'dart:async';
import 'package:connect_4/components/level.dart';
import 'package:connect_4/components/player.dart';
class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks{
  Color backgroundColour() => const Color(0xFF211F30);
  late final CameraComponent cam;
  Player player = Player(character: 'Ninja Frog');
  late JoystickComponent joystick;
  bool showJoystick=true;
  @override
  FutureOr<void> onLoad() async{
    await images.loadAllImages();
    final world = Level(player: player,levelName: 'Level-01');
    cam=CameraComponent.withFixedResolution(world: world,width: 640, height: 360);
    cam.priority = 1;
    cam.viewfinder.anchor=Anchor.topLeft;
    addAll([cam,world]); 
    if(showJoystick){
      addJoystick();
    }
       // TODO: implement onLoad
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(showJoystick){
      updateJoystick();
    }
    super.update(dt);
  }
  
  void addJoystick() {
    joystick = JoystickComponent(
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Knob.png'),),
      ),
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png'),),
      ),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    add(joystick);
    joystick.priority = 2;
  }
  
  void updateJoystick() {
    switch(joystick.direction){
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;      
        break;
      default:
        player.horizontalMovement = 0; 
        break;
    }
  }
}