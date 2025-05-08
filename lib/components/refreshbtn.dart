import 'dart:async';
import 'package:flame/components.dart';
import 'package:connect_4/reversi.dart';
class Refreshbtn extends SpriteComponent with HasGameRef<Reversi>{
  Vector2 pos;
  Refreshbtn({required this.pos});
  @override
  FutureOr<void> onLoad() async{
    sprite=await Sprite.load("refreshbtn.png");
    size=Vector2(32,32);
    position=pos;
    return super.onLoad();
  }
}