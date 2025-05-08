import 'dart:async';
import 'package:flame/components.dart';
import 'package:connect_4/reversi.dart';
import 'package:flutter/widgets.dart';
class Coins extends PositionComponent with HasGameRef<Reversi>{
  late SpriteAnimationComponent flipAnimation;
  late SpriteComponent stillSprite;
  int xpos;
  int ypos;
  int player=0;
  Map<String,SpriteComponent> spriteTypes={};
  Map<String,SpriteAnimation> animationTypes={};
  Vector2 cointPos;
  String coinColor;
  bool isflipping=false;
  Coins({required this.cointPos, required this.coinColor, required this.xpos, required this.ypos});
  @override
  FutureOr<void> onLoad() async{
    position = cointPos;
    if(coinColor=="black"){player=1;}
    else{player=2;}

    final blackcoin=SpriteComponent(
      sprite: await Sprite.load("blackcoin.png"),
      size: Vector2.all(32),
    );
    final whitecoin=SpriteComponent(
      sprite: await Sprite.load("whitecoin.png"),
      size: Vector2.all(32),
    );
    
    spriteTypes.addAll({"black": blackcoin,"white":whitecoin});
    stillSprite = spriteTypes[coinColor]!;
    
    final flipdownb2w=SpriteAnimation.fromFrameData(game.images.fromCache('flipdown_b2w.png'), SpriteAnimationData.sequenced(
      amount: 13,
      stepTime: 0.05,
      loop: false,
      textureSize: Vector2.all(32)),);
    final flipdownw2b=SpriteAnimation.fromFrameData(game.images.fromCache('flipdown_w2b.png'), SpriteAnimationData.sequenced(
      amount: 13,
      stepTime: 0.05,
      loop: false,
      textureSize: Vector2.all(32)),);
    final flipupb2w=SpriteAnimation.fromFrameData(game.images.fromCache('flipup_b2w.png'), SpriteAnimationData.sequenced(
      amount: 13,
      stepTime: 0.05,
      loop: false,
      textureSize: Vector2.all(32)),);
    final flipupw2b=SpriteAnimation.fromFrameData(game.images.fromCache('flipup_w2b.png'), SpriteAnimationData.sequenced(
      amount: 13,
      stepTime: 0.05,
      loop: false,
      textureSize: Vector2.all(32)),);
    final fliprightb2w=SpriteAnimation.fromFrameData(game.images.fromCache('flipright_b2w.png'), SpriteAnimationData.sequenced(
      amount: 13,
      stepTime: 0.05,
      loop: false,
      textureSize: Vector2.all(32)),);
    final fliprightw2b=SpriteAnimation.fromFrameData(game.images.fromCache('flipright_w2b.png'), SpriteAnimationData.sequenced(
      amount: 13,
      stepTime: 0.05,
      loop: false,
      textureSize: Vector2.all(32)),);
    final flipleftw2b=SpriteAnimation.fromFrameData(game.images.fromCache('flipleft_w2b.png'), SpriteAnimationData.sequenced(
      amount: 13,
      stepTime: 0.05,
      loop: false,
      textureSize: Vector2.all(32)),);
    final flipleftb2w=SpriteAnimation.fromFrameData(game.images.fromCache('flipleft_b2w.png'), SpriteAnimationData.sequenced(
      amount: 13,
      stepTime: 0.05,
      loop: false,
      textureSize: Vector2.all(32)),);
    
    animationTypes.addAll({"b2wdown":flipdownb2w,"w2bdown":flipdownw2b,"b2wup":flipupb2w,"w2bup":flipupw2b,
                           "b2wleft":flipleftb2w,"w2bleft":flipleftw2b,"b2wright":fliprightb2w,"w2bright":fliprightw2b});
    
    add(stillSprite);
    return super.onLoad();
  }

  void flipCoin(String way){
    //print("in");
    String actionType; 
    isflipping=true;
    if(coinColor == "black"){
      actionType="b2w$way";
      coinColor="white";
      player=2;
    }else{
      actionType="w2b$way";
      coinColor="black";
      player=1;
    }
    //print(player);
    remove(stillSprite);
    stillSprite=spriteTypes[coinColor]!;

    flipAnimation = SpriteAnimationComponent(
      animation: animationTypes[actionType],
      size: Vector2.all(32),
    );

    add(flipAnimation);
    flipAnimation.animationTicker?.completed.then((_) {
      remove(flipAnimation);
      isflipping=false;
      add(stillSprite);
    });
  }
}