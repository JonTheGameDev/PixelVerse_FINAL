import 'dart:async';
import 'package:flame/components.dart';
import 'package:connect_4/reversi.dart';
class Skipmsg extends SpriteComponent with HasGameRef<Reversi>{
  late Sprite blackskip;
  late Sprite whiteskip;
  int skippingCoin;
  Skipmsg({required this.skippingCoin});
  @override
  FutureOr<void> onLoad() async{
    blackskip=await Sprite.load("blackskips.png");
    whiteskip=await Sprite.load("whiteskips.png");
    if(skippingCoin==1){
      sprite=blackskip;
    }else{
      sprite=whiteskip;
    }
    size=Vector2(128,32);
    position=Vector2(128,176);
    return super.onLoad();
  }
}