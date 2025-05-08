import 'dart:async';
import 'package:flame/components.dart';
import 'package:connect_4/connect_4.dart';
class Winmsg extends SpriteComponent with HasGameRef<Connect4>{
  String message;
  Winmsg({required this.message});
  @override
  FutureOr<void> onLoad() async{
    sprite = await Sprite.load("$message.png");
    position = Vector2(192,32);
    return super.onLoad();
  }
}