import 'dart:async';
import 'package:flame/components.dart';
import 'package:connect_4/reversi.dart';
class Connect4Turnmsg extends SpriteComponent with HasGameRef<Reversi>{
  late Sprite redturn;
  late Sprite yellowturn;
  @override
  FutureOr<void> onLoad() async{
    redturn= await Sprite.load("redturn.png");
    yellowturn= await Sprite.load("yellowturn.png");
    sprite=redturn;
    size=Vector2(96,32);
    return super.onLoad();
  }
  void changeTurn(int player){
    sprite=(player==0)?redturn:yellowturn;
  }
}