import 'dart:async';
import 'package:flame/components.dart';
import 'package:connect_4/connect_4.dart';
class WaitingMsg extends SpriteComponent with HasGameRef<Connect4>{
  @override
  FutureOr<void> onLoad() async{
    sprite = await Sprite.load("waiting_msg.png");
    position = Vector2(176,160);
    return super.onLoad();
  }
}