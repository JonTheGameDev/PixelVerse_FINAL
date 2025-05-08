import 'dart:async';
import 'package:flame/components.dart';
import 'package:connect_4/connect_4.dart';
class Endmsg extends SpriteComponent with HasGameRef<Connect4>{
  String message;
  Endmsg({required this.message});
  @override
  FutureOr<void> onLoad() async{
    sprite = await Sprite.load("$message.png");
    position = Vector2(128,176);
    return super.onLoad();
  }
}