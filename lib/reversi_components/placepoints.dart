import 'dart:async';
import 'package:flame/components.dart';
import 'package:connect_4/reversi.dart';

class Placepoints extends SpriteComponent with HasGameRef<Reversi>{
  Vector2 pos;
  Placepoints({required this.pos});
  @override
  FutureOr<void> onLoad() async{
    sprite = await Sprite.load("placepoint.png");
    position = Vector2(pos.y*32+64,pos.x*32+64);
    return super.onLoad();
  }
}