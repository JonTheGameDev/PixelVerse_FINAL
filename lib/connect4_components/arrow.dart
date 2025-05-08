import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flame/components.dart';
import 'package:connect_4/connect_4.dart';
import 'package:flame_tiled/flame_tiled.dart';

enum ArrowState {idle}
class Arrow extends SpriteAnimationGroupComponent with HasGameRef<Connect4>, KeyboardHandler{
  late final SpriteAnimation idleAnimation;
  final double stepTime = 0.1;
  int arrowCurrentPos=3;
  int direction=0;
  bool canPress=true;
  bool hasMoved=false;
  Arrow({required this.paths});
  List<TiledObject> paths;
  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }
  void _loadAllAnimations(){
    idleAnimation = SpriteAnimation.fromFrameData(game.images.fromCache('arrow_anim.png'), SpriteAnimationData.sequenced(
      amount: 7,
      stepTime: stepTime,
      textureSize: Vector2.all(32)),);

    animations = {
      ArrowState.idle: idleAnimation,
    };

    current = ArrowState.idle; 
  }

  @override
  void update(double dt) {
    _updateArrow();
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) { 
    if (event is KeyDownEvent && canPress){
      if(event.logicalKey == LogicalKeyboardKey.keyA || event.logicalKey == LogicalKeyboardKey.arrowLeft){
        direction=1;
        canPress=false;
      }else if(event.logicalKey == LogicalKeyboardKey.keyD || event.logicalKey == LogicalKeyboardKey.arrowRight){
        direction=2;
        canPress=false;
      }
    }
    else if(event is KeyUpEvent ){
      if(event.logicalKey == LogicalKeyboardKey.keyA || event.logicalKey == LogicalKeyboardKey.arrowLeft
        ||event.logicalKey == LogicalKeyboardKey.keyD || event.logicalKey == LogicalKeyboardKey.arrowRight){
          canPress=true;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }


  void _updateArrow() {  
    if(direction == 1){
      if(arrowCurrentPos>0){
        arrowCurrentPos-=1;
        direction=0;
        position = paths[arrowCurrentPos].position;
        hasMoved=true;
      }
    }
    else if(direction == 2){
      if(arrowCurrentPos<6){
        arrowCurrentPos+=1;
        direction=0;
        position = paths[arrowCurrentPos].position;
        hasMoved=true; 
      }
    }
  }
}