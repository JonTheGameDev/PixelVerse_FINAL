import 'dart:async';
import 'package:flame/components.dart';
import 'package:connect_4/reversi.dart';
class Turnmsg extends SpriteComponent with HasGameRef<Reversi>{
  late Sprite blackturn;
  late Sprite whiteturn;
  @override
  FutureOr<void> onLoad() async{
    blackturn= await Sprite.load("blackturn.png");
    whiteturn= await Sprite.load("whiteturn.png");
    sprite=blackturn;
    size=Vector2(96,32);
    return super.onLoad();
  }
  void changeTurn(int player){
    sprite=(player==1)?blackturn:whiteturn;
  }
}