import 'dart:async';
import 'package:flame/components.dart';
import 'package:connect_4/reversi.dart';
class Scoreboard extends PositionComponent with HasGameRef<Reversi>{
  List<Sprite> blackscores=[];
  List<Sprite> whitescores=[];
  late SpriteComponent blkscoretenths;
  late SpriteComponent blkscoreones;
  late SpriteComponent whtscoretenths;
  late SpriteComponent whtscoreones;
  @override
  FutureOr<void> onLoad() async{
    final spriteb0= await Sprite.load("b0.png");
    final spriteb1= await Sprite.load("b1.png");
    final spriteb2= await Sprite.load("b2.png");
    final spriteb3= await Sprite.load("b3.png");
    final spriteb4= await Sprite.load("b4.png");
    final spriteb5= await Sprite.load("b5.png");
    final spriteb6= await Sprite.load("b6.png");
    final spriteb7= await Sprite.load("b7.png");
    final spriteb8= await Sprite.load("b8.png");
    final spriteb9= await Sprite.load("b9.png");
    final spritew0= await Sprite.load("w0.png");
    final spritew1= await Sprite.load("w1.png");
    final spritew2= await Sprite.load("w2.png");
    final spritew3= await Sprite.load("w3.png");
    final spritew4= await Sprite.load("w4.png");
    final spritew5= await Sprite.load("w5.png");
    final spritew6= await Sprite.load("w6.png");
    final spritew7= await Sprite.load("w7.png");
    final spritew8= await Sprite.load("w8.png");
    final spritew9= await Sprite.load("w9.png");
    blackscores.addAll([spriteb0,spriteb1,spriteb2,spriteb3,spriteb4,spriteb5,spriteb6,spriteb7,spriteb8,spriteb9]);
    whitescores.addAll([spritew0,spritew1,spritew2,spritew3,spritew4,spritew5,spritew6,spritew7,spritew8,spritew9,]);
    blkscoreones=SpriteComponent(sprite:spriteb2,size:Vector2(16,32),position: Vector2(24, 160));
    blkscoretenths=SpriteComponent(sprite:spriteb0,size:Vector2(16,32),position: Vector2(8, 160));
    whtscoreones=SpriteComponent(sprite:spritew2,size:Vector2(16,32),position: Vector2(360, 160));
    whtscoretenths=SpriteComponent(sprite:spritew0,size:Vector2(16,32),position: Vector2(344, 160));
    addAll([blkscoreones,blkscoretenths,whtscoreones,whtscoretenths]);
    return super.onLoad();
  }
  void updateScore(int black,int white){
    removeAll([blkscoreones,blkscoretenths,whtscoreones,whtscoretenths]);
    blkscoreones=SpriteComponent(sprite:blackscores[black%10],size:Vector2(16,32),position: Vector2(24, 160));
    blkscoretenths=SpriteComponent(sprite:blackscores[(black/10).floor()],size:Vector2(16,32),position: Vector2(8, 160));
    whtscoreones=SpriteComponent(sprite:whitescores[white%10],size:Vector2(16,32),position: Vector2(360, 160));
    whtscoretenths=SpriteComponent(sprite:whitescores[(white/10).floor()],size:Vector2(16,32),position: Vector2(344, 160));
    addAll([blkscoreones,blkscoretenths,whtscoreones,whtscoretenths]);
  }
}