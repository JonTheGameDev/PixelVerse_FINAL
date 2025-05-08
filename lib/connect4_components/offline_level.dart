import 'dart:async';
import 'dart:io';
import 'package:connect_4/components/refreshbtn.dart';
import 'package:connect_4/connect4_components/drop_arrow.dart';
import 'package:connect_4/connect4_components/endmsg.dart';
import 'package:connect_4/connect4_components/turnmsg.dart';
import 'package:connect_4/connect_4.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:connect_4/connect4_components/arrow.dart';
import 'package:connect_4/connect4_components/coin.dart';
import 'package:flutter/services.dart';
//import 'package:connect_4/actors/player.dart';
class OfflineLevel extends World with HasGameRef<Connect4>,KeyboardHandler,TapCallbacks{
  late TiledComponent level;
  late TiledComponent levelFront;
  List<TiledObject> paths = [];
  List<Coin> coins=[];
  List<DropArrow> darros=[];
  List<Winmsg> msg=[];
  List<String> coinColors = ["red_coin","yellow_coin"];
  var playerPlacements=[[-1,-1,-1,-1,-1,-1,-1],
                        [-1,-1,-1,-1,-1,-1,-1],
                        [-1,-1,-1,-1,-1,-1,-1],
                        [-1,-1,-1,-1,-1,-1,-1],
                        [-1,-1,-1,-1,-1,-1,-1],
                        [-1,-1,-1,-1,-1,-1,-1]];
  var fallDepth=[288,256,224,192,160,128];
  var columnFallDepth=[0,0,0,0,0,0,0];
  int colorTurn=0;
  bool refreshing=false;
  bool canPress=true;
  bool isSpacePressed=false;
  bool gameWon=false;
  bool gameend=false;
  bool isAndroid = Platform.isAndroid;
  bool reset=false;
  int winner = -1;
  late Refreshbtn refbtn;
  Arrow arrow=Arrow(paths: []);
  Coin previousCoin=Coin(cointPos: Vector2.zero(),coinColor: "red_coin",fallDepth: 0);
  Connect4Turnmsg turnmsg=Connect4Turnmsg();
  @override
  FutureOr<void> onLoad() async{

    level=await TiledComponent.load('board.tmx', Vector2.all(32));
    add(level);
    levelFront=await TiledComponent.load('board_front.tmx', Vector2.all(32));
    add(levelFront);
    levelFront.priority = 2;
    final spawnPointLayer =level.tileMap.getLayer<ObjectGroup>('test'); 
    for(final spawnPoint in spawnPointLayer!.objects){
          paths.add(spawnPoint);
    }
    if(isAndroid){
      int i=0,timesplt;
      for(final points in paths){
        if(i==3){
          timesplt=500;
        }else if(i==2 || i==4){
          timesplt=600;
        }else if(i==1 || i==5){
          timesplt=700;
        }else{
          timesplt=800;
        }
        final DropArrow droparrow=DropArrow(arrowPos: points.position,timesplit: timesplt);
        darros.add(droparrow);
        i++;
      }
      addAll(darros);
    }
    refbtn=Refreshbtn(pos: Vector2(448,0));
    add(refbtn);
    add(turnmsg);
    final Arrow arrow = Arrow(paths: paths);
    arrow.position = paths[3].position;
    this.arrow=arrow;
    if(!isAndroid)
      add(arrow);
    previousCoin.isFalling=false;
    return super.onLoad();
  }

  @override
  void update(double dt) async{
    if(!gameend){
      if(isSpacePressed && columnFallDepth[arrow.arrowCurrentPos]<6 && !arrow.hasMoved && !previousCoin.isFalling && arrow.canPress){
        print(arrow.arrowCurrentPos);
        Coin coin= Coin(cointPos: arrow.position,coinColor: coinColors[colorTurn],fallDepth: fallDepth[columnFallDepth[arrow.arrowCurrentPos]]);
        coins.add(coin);
        playerPlacements[5-columnFallDepth[arrow.arrowCurrentPos]][arrow.arrowCurrentPos]=colorTurn;
        gameWon = _checkWin(5-columnFallDepth[arrow.arrowCurrentPos],arrow.arrowCurrentPos,colorTurn);
        if(gameWon){winner=colorTurn;}
        columnFallDepth[arrow.arrowCurrentPos] += 1;
        add(coin);
        print(arrow.arrowCurrentPos);
        if(arrow.isMounted)
          remove(arrow);
        if(colorTurn==0){colorTurn=1;}else{colorTurn=0;}
        previousCoin=coin;
        canPress=false;
        isSpacePressed=false;
      }
      else if(!previousCoin.isFalling && !canPress){
        turnmsg.changeTurn(colorTurn);
        canPress=true;
        arrow.direction=0;
        arrow.canPress=true;
        if(gameWon){
          String wName;
          if(winner == 1){
            wName="yellow_win_msg";
          }else{
            wName="red_win_msg";
          }
          remove(turnmsg);
          Winmsg msg=Winmsg(message: wName);
          await add(msg);
          this.msg.add(msg);
          gameend=true;
        }else{
          _checkDraw();
        }
        if(!gameWon){
          if(!isAndroid){
            add(arrow);
          }else{
            addAll(darros);
          }
        }
      }

      if(arrow.hasMoved){
        isSpacePressed=false;
        arrow.hasMoved=false;
      }
    }
    if(reset){
      resetGame();
    }
    super.update(dt);
  }
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if(keysPressed.contains(LogicalKeyboardKey.space) && canPress){
      isSpacePressed=true;
    }
    return super.onKeyEvent(event, keysPressed);
  }
  @override
  void onTapDown(TapDownEvent event){
    print(event.localPosition);
    if(canPress && isAndroid && !gameend){
      for(int i=0;i<7;i++){
        final points=paths[i];
        if(event.localPosition.x >= points.x && event.localPosition.x <= points.x+32 && event.localPosition.y >= points.y && event.localPosition.y <= points.y+32){
          print(i);
          arrow.position=paths[i].position;
          arrow.arrowCurrentPos=i;
          isSpacePressed=true;
          removeAll(darros);
          for(final drparrows in darros){
            drparrows.reset();
          }              
        }
      }
    }
    if(event.localPosition.x >= refbtn.x+1 && event.localPosition.x <= refbtn.x+31 && event.localPosition.y >= refbtn.y+1 && event.localPosition.y <= refbtn.y+30 && !refreshing && !previousCoin.isFalling){
      refreshing=true;
      resetGame();
    }
    super.onTapDown(event);
  }
  bool _checkWin(int indexI,int indexJ,int playerTurn) {
    int leftCount=0, rightCount=0, upCount=0, downCount=0, NECount=0, NWCount=0, SECount=0, SWCount=0;
    int i,j;
    if(indexJ!=0){for(int j=indexJ-1;j>=0;j--){
      if(playerPlacements[indexI][j]==playerTurn){
        leftCount ++;
      }else{
        break;
      }     
    }}

    if(indexJ!=6){for(int j=indexJ+1;j<=6;j++){
      if(playerPlacements[indexI][j]==playerTurn){
        rightCount ++;
      }else{
        break;
      }     
    }}

    if(indexI!=0){for(int i=indexI-1;i>=0;i--){
      if(playerPlacements[i][indexJ]==playerTurn){
        upCount ++;
      }else{
        break;
      }     
    }}

    if(indexI!=5){for(int i=indexI+1;i<=5;i++){
      if(playerPlacements[i][indexJ]==playerTurn){
        downCount ++;
      }else{
        break;
      }     
    }}

    if(indexI!=0 && indexJ!=0){
      i=indexI-1;
      j=indexJ-1;
      while(i>=0 && j>=0 && playerPlacements[i][j]==playerTurn){
        NWCount ++;
        i--;
        j--;
      }
    }

    if(indexI!=5 && indexJ!=6){
      i=indexI+1;
      j=indexJ+1;
      while(i<=5 && j<=6 && playerPlacements[i][j]==playerTurn){
        SECount ++;
        i++;
        j++;
      }
    }

    if(indexI!=0 && indexJ!=6){
      i=indexI-1;
      j=indexJ+1;
      while(i>=0 && j<=6 && playerPlacements[i][j]==playerTurn){
        NECount ++;
        i--;
        j++;
      }
    }

    if(indexI!=5 && indexJ!=0){
      i=indexI+1;
      j=indexJ-1;
      while(i<=5 && j>=0 && playerPlacements[i][j]==playerTurn){
        SWCount ++;
        i++;
        j--;
      }
    }

    if(leftCount+rightCount>=3 || upCount+downCount>=3 || NECount+SWCount>=3 || NWCount+SECount>=3){
      return true;
    }else{
      return false;
    }
  }
  
  void _checkDraw() {
    bool isTie=true;
    for(int i=0;i<=6;i++){
      if(columnFallDepth[i]!=6){isTie=false;}
    }
    if(isTie){
      Winmsg msg=Winmsg(message: "tie_msg");
      add(msg);
      this.msg.add(msg);
      gameend=true;
    }
  }
  
  void resetGame() {
    print("Reseting");
    removeAll(coins);
    for(final msgs in  msg){
      if(msgs.isMounted){remove(msgs);}
    }
    if(isAndroid && darros[0].isMounted){
      removeAll(darros);
    }
    turnmsg.changeTurn(0);
    playerPlacements=[[-1,-1,-1,-1,-1,-1,-1],
                      [-1,-1,-1,-1,-1,-1,-1],
                      [-1,-1,-1,-1,-1,-1,-1],
                      [-1,-1,-1,-1,-1,-1,-1],
                      [-1,-1,-1,-1,-1,-1,-1],
                      [-1,-1,-1,-1,-1,-1,-1]];
    columnFallDepth=[0,0,0,0,0,0,0];
    colorTurn=0;
    coins=[];
    msg=[];
    gameend=false; 
    reset=false;
    refreshing=false;
  }
}