import 'dart:async';
import 'package:flame/components.dart';
import 'package:connect_4/connect_4.dart';

class DropArrow extends SpriteComponent with HasGameRef<Connect4>{
  Vector2 arrowPos;
  int timesplit;
  int dir=1;
  bool moving=false;
  bool begin=false;
  bool resetting=false;
  DropArrow({required this.arrowPos,required this.timesplit});
  @override
  FutureOr<void> onLoad() async{
    sprite = await Sprite.load("drop_arrow.png");
    position = arrowPos;
    Future.delayed(Duration(milliseconds: timesplit), () {
      begin=true;
    });
    return super.onLoad();
  }
  void reset(){
    begin=false;
    dir=1;
    position=arrowPos;
    Future.delayed(Duration(milliseconds: 401+timesplit), () {
      begin=true;
      moving=false;
    });
  }
  @override
  void update(double dt) {
    if(begin){
      if(dir==1 && !moving){
        moving=true;
        Future.delayed(Duration(milliseconds: 500), () {
          if(begin){
          dir=2;
          moving=false;
          }});
      }else if(dir==2 && !moving){
        moving=true;
      }else if(dir==1 && moving){
        position.y-=10*dt;
      }else if(dir==2 && moving && position.y<arrowPos.y){
        position.y+=20*dt;
      }else if(position.y>=arrowPos.y && moving){
        moving=false;
        dir=0;
        Future.delayed(Duration(milliseconds: 500), () {
          if(begin){dir=1;}
        });
      }
    }
    super.update(dt);
  }
}