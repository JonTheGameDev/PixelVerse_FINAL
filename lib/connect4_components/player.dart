import 'dart:async';

import 'package:flame/components.dart';
import 'package:connect_4/connect_4.dart';
enum PlayerState {idle}
class Player extends SpriteAnimationGroupComponent with HasGameRef<Connect4>{
  late final SpriteAnimation idleAnimation;
  final double stepTime = 0.1;
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
      PlayerState.idle: idleAnimation,
    };

    current = PlayerState.idle; 
  }
}