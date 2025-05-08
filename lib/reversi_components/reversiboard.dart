import 'dart:async';
import 'package:connect_4/components/refreshbtn.dart';
import 'package:connect_4/reversi.dart';
import 'package:connect_4/reversi_components/endmsg.dart';
import 'package:connect_4/reversi_components/scoreboard.dart';
import 'package:connect_4/reversi_components/skipmsg.dart';
import 'package:connect_4/reversi_components/turnmsg.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:connect_4/reversi_components/coins.dart';
import 'package:connect_4/reversi_components/placepoints.dart';
import 'package:flutter/services.dart';
class Board extends World with HasGameRef<Reversi>,KeyboardHandler,TapCallbacks{
  late TiledComponent level;
  List<TiledObject> paths = [];
  List<Vector2> placepts=[];
  List<Placepoints> placablepts=[];
  Turnmsg turnmsg=Turnmsg();
  Scoreboard scoreboard=Scoreboard();
  List<Endmsg> emsg=[];
  bool gameend=false;
  late Refreshbtn refbtn;
  var placements=[[0,0,0,0,0,0,0,0],
                  [0,0,0,0,0,0,0,0],
                  [0,0,0,0,0,0,0,0],
                  [0,0,0,0,0,0,0,0],
                  [0,0,0,0,0,0,0,0],
                  [0,0,0,0,0,0,0,0],
                  [0,0,0,0,0,0,0,0],
                  [0,0,0,0,0,0,0,0]];
  var reference=[[0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0],
                 [0,0,0,0,0,0,0,0]];
  List<Coins> coins=[];
  int colorTurn=1;
  @override
  FutureOr<void> onLoad() async{
    level=await TiledComponent.load('untitled.tmx', Vector2.all(32));
    add(level);
    final spawnPointLayer =level.tileMap.getLayer<ObjectGroup>('CoinSpawns'); 
    for(final spawnPoint in spawnPointLayer!.objects){
          paths.add(spawnPoint);
    }
    refbtn=Refreshbtn(pos: Vector2(352,0));
    add(refbtn);
    add(turnmsg);
    add(scoreboard);
    _loadStartState();
    return super.onLoad();
  }
  @override
  void onTapDown(TapDownEvent event){
    print(event.localPosition);
    if(checkFlipCompletion() && !gameend){
      if(event.localPosition.x >=64 && event.localPosition.y >=64 && event.localPosition.x <=320 && event.localPosition.y <=320){
        for(final points in paths){
          if(event.localPosition.x >= points.x && event.localPosition.x <= points.x+32 && event.localPosition.y >= points.y && event.localPosition.y <= points.y+32){
            String color;
            int xpos=(points.x/32-2).toInt();
            int ypos=(points.y/32-2).toInt();
            if(placepts.contains(Vector2(ypos.toDouble(),xpos.toDouble())) && placements[ypos][xpos]==0){
              placements[ypos][xpos]=colorTurn;
              if(colorTurn==1){
                color="black";
                colorTurn=2;
              }else{
                color="white";
                colorTurn=1;
              }
              print("working");
              Coins coin=Coins(cointPos: points.position,coinColor: color,xpos: xpos,ypos: ypos);
              add(coin);
              reference[ypos][xpos]=coins.length;
              coins.add(coin);
              print(reference);
              print(placements);
              removeAll(placablepts);
              checkGameState();
            }
          }
        }
      }
    }
    if(event.localPosition.x >= refbtn.x+1 && event.localPosition.x <= refbtn.x+31 && event.localPosition.y >= refbtn.y+1 && event.localPosition.y <= refbtn.y+30 && checkFlipCompletion()){
      resetGame();
    }
    super.onTapDown(event);
  }
  
  void _loadStartState() async{
    final coin1=Coins(cointPos: Vector2.all(160),coinColor: "white",xpos: 3,ypos: 3);
    await add(coin1);
    reference[3][3]=coins.length;
    placements[3][3]=2;
    coins.add(coin1);
    final coin2=Coins(cointPos: Vector2(192,160),coinColor: "black",xpos: 4,ypos: 3);
    await add(coin2);
    reference[3][4]=coins.length;
    placements[3][4]=1;
    coins.add(coin2);
    final coin3=Coins(cointPos: Vector2(160,192),coinColor: "black",xpos: 3,ypos: 4);
    await add(coin3);
    reference[4][3]=coins.length;
    placements[4][3]=1;
    coins.add(coin3);
    final coin4=Coins(cointPos: Vector2.all(192),coinColor: "white",xpos: 4,ypos: 4);
    await add(coin4);
    reference[4][4]=coins.length;
    placements[4][4]=2;
    coins.add(coin4);
    placepts.addAll([Vector2(2,3),Vector2(3,2),Vector2(4,5),Vector2(5,4)]);
    for (final plcpts in placepts){
      Placepoints pt=Placepoints(pos: plcpts);
      placablepts.add(pt);
    }
    addAll(placablepts);
  }
  
  void checkGameState() async{
    Coins lastcoin=coins.last;
    int player=coins.last.player;
    bool canflip;
    int xpos=lastcoin.xpos,ypos=lastcoin.ypos;
    int k,i,j;
    var coinFlipRef=[[-1,-1,-1,-1,-1,-1,-1],  //for upward flip
                     [-1,-1,-1,-1,-1,-1,-1],  //for upward flip on NE
                     [-1,-1,-1,-1,-1,-1,-1],  //for upward flip on NW
                     [-1,-1,-1,-1,-1,-1,-1],  //for downward flip
                     [-1,-1,-1,-1,-1,-1,-1],  //for downward flip on SE
                     [-1,-1,-1,-1,-1,-1,-1],  //for downward flip on SW
                     [-1,-1,-1,-1,-1,-1,-1],  //for leftward flip
                     [-1,-1,-1,-1,-1,-1,-1]];//for rightward flip
    if(ypos!=0){
      k=0;
      canflip=false;
      for(int i=ypos-1;i>=0;i--){
        if(placements[i][xpos]!=0){
          if(placements[i][xpos]!=player){
            coinFlipRef[0][k]=reference[i][xpos];
            k++;
            print("opponet's up");
          }
          else{
            canflip=true;
            break;
          }
        }
        else{
          break;
        }
      }
      if(!canflip){
        coinFlipRef[0]=[-1,-1,-1,-1,-1,-1,-1];
      }
    }
    if(xpos!=7 && ypos!=0){
      k=0;
      canflip=false;
      j=xpos+1;
      i=ypos-1;
      while(i>=0 && j<=7){
        if(placements[i][j]!=0){
          if(placements[i][j]!=player){
            coinFlipRef[1][k]=reference[i][j];
            k++;
            print("opponet's NE");
          }
          else{
            canflip=true;
            break;
          }
        }
        else{
          break;
        }
        i--;
        j++;
      }
      if(!canflip){
        coinFlipRef[1]=[-1,-1,-1,-1,-1,-1,-1];
      }
    }
    if(xpos!=0 && ypos!=0){
      k=0;
      canflip=false;
      j=xpos-1;
      i=ypos-1;
      while(i>=0 && j>=0){
        if(placements[i][j]!=0){
          if(placements[i][j]!=player){
            coinFlipRef[2][k]=reference[i][j];
            k++;
            print("opponet's NW");
          }
          else{
            canflip=true;
            break;
          }
        }
        else{
          break;
        }
        i--;
        j--;
      }
      if(!canflip){
        coinFlipRef[2]=[-1,-1,-1,-1,-1,-1,-1];
      }
    }
    if(ypos!=7){
      k=0;
      canflip=false;
      for(int i=ypos+1;i<=7;i++){
        if(placements[i][xpos]!=0){
          if(placements[i][xpos]!=player){
            coinFlipRef[3][k]=reference[i][xpos];
            k++;
            print("opponet's down");
          }
          else{
            canflip=true;
            break;
          }
        }
        else{
          break;
        }
      }
      if(!canflip){
        coinFlipRef[3]=[-1,-1,-1,-1,-1,-1,-1];
      }
    }
    if(xpos!=7 && ypos!=7){
      k=0;
      canflip=false;
      j=xpos+1;
      i=ypos+1;
      while(i<=7 && j<=7){
        if(placements[i][j]!=0){
          if(placements[i][j]!=player){
            coinFlipRef[4][k]=reference[i][j];
            k++;
            print("opponet's SE");
          }
          else{
            canflip=true;
            break;
          }
        }
        else{
          break;
        }
        i++;
        j++;
      }
      if(!canflip){
        coinFlipRef[4]=[-1,-1,-1,-1,-1,-1,-1];
      }
    }
    if(xpos!=0 && ypos!=7){
      k=0;
      canflip=false;
      j=xpos-1;
      i=ypos+1;
      while(i<=7 && j>=0){
        if(placements[i][j]!=0){
          if(placements[i][j]!=player){
            coinFlipRef[5][k]=reference[i][j];
            k++;
            print("opponet's SW");
          }
          else{
            canflip=true;
            break;
          }
        }
        else{
          break;
        }
        i++;
        j--;
      }
      if(!canflip){
        coinFlipRef[5]=[-1,-1,-1,-1,-1,-1,-1];
      }
    }
    if(xpos!=0){
      k=0;
      canflip=false;
      for(int j=xpos-1;j>=0;j--){
        if(placements[ypos][j]!=0){
          if(placements[ypos][j]!=player){
            coinFlipRef[6][k]=reference[ypos][j];
            k++;
            print("opponet's left");
          }
          else{
            canflip=true;
            break;
          }
        }
        else{
          break;
        }
      }
      if(!canflip){
        coinFlipRef[6]=[-1,-1,-1,-1,-1,-1,-1];
      }
    }
    if(xpos!=7){
      k=0;
      canflip=false;
      for(int j=xpos+1;j<=7;j++){
        if(placements[ypos][j]!=0){
          if(placements[ypos][j]!=player){
            coinFlipRef[7][k]=reference[ypos][j];
            k++;
            print("opponet's right");
          }
          else{
            canflip=true;
            break;
          }
        }
        else{
          break;
        }
      }
      if(!canflip){
        coinFlipRef[7]=[-1,-1,-1,-1,-1,-1,-1];
      }
    }
    
    for(int i=0;i<6;i++){
        Future.delayed(Duration(milliseconds: 100*i), () {
          if(coinFlipRef[0][i]!=-1){
          coins[coinFlipRef[0][i]].flipCoin("up");
          placements[coins[coinFlipRef[0][i]].ypos][coins[coinFlipRef[0][i]].xpos]=coins[coinFlipRef[0][i]].player;
        }
        if(coinFlipRef[1][i]!=-1){
          coins[coinFlipRef[1][i]].flipCoin("up");
          placements[coins[coinFlipRef[1][i]].ypos][coins[coinFlipRef[1][i]].xpos]=coins[coinFlipRef[1][i]].player;
        }
        if(coinFlipRef[2][i]!=-1){
          coins[coinFlipRef[2][i]].flipCoin("up");
          placements[coins[coinFlipRef[2][i]].ypos][coins[coinFlipRef[2][i]].xpos]=coins[coinFlipRef[2][i]].player;
        }
        if(coinFlipRef[3][i]!=-1){
          coins[coinFlipRef[3][i]].flipCoin("down");
          placements[coins[coinFlipRef[3][i]].ypos][coins[coinFlipRef[3][i]].xpos]=coins[coinFlipRef[3][i]].player;
        }
        if(coinFlipRef[4][i]!=-1){
          coins[coinFlipRef[4][i]].flipCoin("down");
          placements[coins[coinFlipRef[4][i]].ypos][coins[coinFlipRef[4][i]].xpos]=coins[coinFlipRef[4][i]].player;
        }
        if(coinFlipRef[5][i]!=-1){
          coins[coinFlipRef[5][i]].flipCoin("down");
          placements[coins[coinFlipRef[5][i]].ypos][coins[coinFlipRef[5][i]].xpos]=coins[coinFlipRef[5][i]].player;
        }
        if(coinFlipRef[6][i]!=-1){
          coins[coinFlipRef[6][i]].flipCoin("left");
          placements[coins[coinFlipRef[6][i]].ypos][coins[coinFlipRef[6][i]].xpos]=coins[coinFlipRef[6][i]].player;
        }
        if(coinFlipRef[7][i]!=-1){
          coins[coinFlipRef[7][i]].flipCoin("right");
          placements[coins[coinFlipRef[7][i]].ypos][coins[coinFlipRef[7][i]].xpos]=coins[coinFlipRef[7][i]].player;
        }
        });
    }
    Future.delayed(Duration(milliseconds: 600), () {
      int b=0,w=0;
      for(int i=0;i<8;i++){
        for(int j=0;j<8;j++){
          if (placements[i][j]==1){
            b++;
          }else if(placements[i][j]==2){
            w++;
          }
        }
      }
      scoreboard.updateScore(b,w);
      modifySpawnPoints();
    });
  }
  
  void modifySpawnPoints() {
    int xpos;
    int ypos;
    int player;
    bool placable;
    int k=0,i,j;
    placepts=[];
    for(final cns in coins){
      ypos=cns.ypos;
      xpos=cns.xpos;
      player=cns.player;
      
      if(ypos!=0 && ypos<7 && placements[ypos-1][xpos]==0 && player!=colorTurn){
        placable=false;
        for(int i=ypos+1;i<=7;i++){
          if(placements[i][xpos]!=0){
            if(placements[i][xpos]==colorTurn){
              placable=true;
              k++;
              break;
            }
          }
          else{
            break;
          }
        }
        if(placable){placepts.add(Vector2((ypos-1).toDouble(),xpos.toDouble()));}
      }
      if(ypos!=7 && ypos>0 && placements[ypos+1][xpos]==0 && player!=colorTurn){
        placable=false;
        for(int i=ypos-1;i>=0;i--){
          if(placements[i][xpos]!=0){
            if(placements[i][xpos]==colorTurn){
              placable=true;
              k++;
              break;
            }
          }
          else{
            break;
          }
        }
        if(placable){placepts.add(Vector2((ypos+1).toDouble(),xpos.toDouble()));}
      }
      if(xpos!=0 && xpos<7 && placements[ypos][xpos-1]==0 && player!=colorTurn){
        placable=false;
        for(int i=xpos+1;i<=7;i++){
          if(placements[ypos][i]!=0){
            if(placements[ypos][i]==colorTurn){
              placable=true;
              k++;
              break;
            }
          }
          else{
            break;
          }
        }
        if(placable){placepts.add(Vector2(ypos.toDouble(),(xpos-1).toDouble()));}
      }
      if(xpos!=7 && xpos>0 && placements[ypos][xpos+1]==0 && player!=colorTurn){
        placable=false;
        for(int i=xpos-1;i>=0;i--){
          if(placements[ypos][i]!=0){
            if(placements[ypos][i]==colorTurn){
              placable=true;
              k++;
              break;
            }
          }
          else{
            break;
          }
        }
        if(placable){placepts.add(Vector2(ypos.toDouble(),(xpos+1).toDouble()));}
      }
      if(xpos!=7 && ypos!=0 && placements[ypos-1][xpos+1]==0 && player!=colorTurn){
      placable=false;
      j=xpos-1;
      i=ypos+1;
        while(i<=7 && j>=0){
          if(placements[i][j]!=0){
            if(placements[i][j]==colorTurn){
              placable=true;
              k++;
              break;
            }
          }else{
            break;
          }
          i++;
          j--;
        }
        if(placable){placepts.add(Vector2((ypos-1).toDouble(),(xpos+1).toDouble()));}
      }
      if(xpos!=0 && ypos!=7 && placements[ypos+1][xpos-1]==0 && player!=colorTurn){
      placable=false;
      j=xpos+1;
      i=ypos-1;
        while(i>=0 && j<=7){
          if(placements[i][j]!=0){
            if(placements[i][j]==colorTurn){
              placable=true;
              k++;
              break;
            }
          }else{
            break;
          }
          i--;
          j++;
        }
        if(placable){placepts.add(Vector2((ypos+1).toDouble(),(xpos-1).toDouble()));}
      }
      if(xpos!=0 && ypos!=0 && placements[ypos-1][xpos-1]==0 && player!=colorTurn){
      placable=false;
      j=xpos+1;
      i=ypos+1;
        while(i<=7 && j<=7){
          if(placements[i][j]!=0){
            if(placements[i][j]==colorTurn){
              placable=true;
              k++;
              break;
            } 
          }else{
            break;
          }
          i++;
          j++;
        }
        if(placable){placepts.add(Vector2((ypos-1).toDouble(),(xpos-1).toDouble()));}
      }
      if(xpos!=7 && ypos!=7 && placements[ypos+1][xpos+1]==0 && player!=colorTurn){
      placable=false;
      j=xpos-1;
      i=ypos-1;
        while(i>=0 && j>=0){
          if(placements[i][j]!=0){
            if(placements[i][j]==colorTurn){
              placable=true;
              k++;
              break;
            }
          }else{
            break;
          }
          i--;
          j--;
        }
        if(placable){placepts.add(Vector2((ypos+1).toDouble(),(xpos+1).toDouble()));}
      }
    }  
    if(k!=0){
      addPlacablePts();
    }else{
      if(!gameEnd()){
        showSkipMsg(colorTurn);
        if(colorTurn==1){
          colorTurn=2;
        }else{
          colorTurn=1;
        }
        Future.delayed(Duration(milliseconds: 1500), () {
          modifySpawnPoints();
        });
      }
    }  
  }
  
  void addPlacablePts() {
    placablepts=[];
    for (final plcpts in placepts){
      Placepoints pt=Placepoints(pos: plcpts);
      placablepts.add(pt);
    }
    turnmsg.changeTurn(colorTurn);
    addAll(placablepts);
  }
  
  bool checkFlipCompletion() {
    for(final cns in coins){
      if(cns.isflipping){
        return false;
      }
    }
    return true;
  }
  
  bool gameEnd() {
    for(int i=0;i<8;i++){
      for(int j=0;j<8;j++){
        if (placements[i][j]==0){
          return false;
        }
      }
    }
    int b=0,w=0;
    for(int i=0;i<8;i++){
      for(int j=0;j<8;j++){
        if (placements[i][j]==1){
          b++;
        }else{
          w++;
        }
      }
    }
    Endmsg emsg;
    if(w>b){
      emsg=Endmsg(message: "white_win");
    }else if(b>w){
      emsg=Endmsg(message: "black_win");
    }else{
      emsg=Endmsg(message: "tie_end");
    }
    add(emsg);
    remove(turnmsg);
    this.emsg.add(emsg);
    gameend=true;
    return true;
  }
  
  void showSkipMsg(int player) {
    Skipmsg skipmsg=Skipmsg(skippingCoin: player);
    add(skipmsg);
    Future.delayed(Duration(milliseconds: 1500), () {
          remove(skipmsg);
    });
  }
  
  void resetGame() {
    placements=[[0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0]];
    reference=[[0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0],
                [0,0,0,0,0,0,0,0]];
    removeAll(placablepts);
    placepts=[];
    placablepts=[];
    colorTurn=1;
    removeAll(coins);
    coins=[];
    removeAll(emsg);
    emsg=[];
    add(turnmsg);
    turnmsg.changeTurn(1);
    _loadStartState();
    scoreboard.updateScore(2, 2);
  }
}