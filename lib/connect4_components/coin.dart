import 'dart:async';
import 'package:flame/components.dart';
import 'package:connect_4/connect_4.dart';

class Coin extends SpriteComponent with HasGameRef<Connect4>{
  Vector2 cointPos;
  String coinColor;
  int fallDepth;
  int fallSpeed=200;
  bool isFalling=true;
  Coin({required this.cointPos, required this.coinColor, required this.fallDepth});
  @override
  FutureOr<void> onLoad() async{
    sprite = await Sprite.load("$coinColor.png");
    position = cointPos;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(isFalling){
      _coinFall(dt);
    }
    super.update(dt);
  }
  
  void _coinFall(double dt) {
    if(position.y+height<fallDepth){
      position.y +=fallSpeed*dt;
    }else{
      position.y=fallDepth-height;
      isFalling=false;
    }
  }
}