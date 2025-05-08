import 'dart:async';
import 'dart:io';
import 'package:connect_4/connect4_components/drop_arrow.dart';
import 'package:connect_4/connect4_components/turnmsg.dart';
import 'package:connect_4/connect4_components/endmsg.dart';
import 'package:connect_4/connect4_components/waiting_msg.dart';
import 'package:connect_4/connect_4.dart';
import 'package:connect_4/login.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:connect_4/connect4_components/arrow.dart';
import 'package:connect_4/connect4_components/coin.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';
//import 'package:connect_4/actors/player.dart';
class Level extends World with HasGameRef<Connect4>,KeyboardHandler,TapCallbacks{
  String playerId=playerid;
  final supabase = Supabase.instance.client;
  RealtimeChannel? channel;
  late TiledComponent level;
  late TiledComponent levelFront;
  List<TiledObject> paths = [];
  List<DropArrow> darros=[];
  List<Coin> coins=[];
  List<Winmsg> msg=[];
  List<String> coinColors = ["red_coin","yellow_coin"];
  late var playerPlacements=[[-1,-1,-1,-1,-1,-1,-1],
                        [-1,-1,-1,-1,-1,-1,-1],
                        [-1,-1,-1,-1,-1,-1,-1],
                        [-1,-1,-1,-1,-1,-1,-1],
                        [-1,-1,-1,-1,-1,-1,-1],
                        [-1,-1,-1,-1,-1,-1,-1]];
  var fallDepth=[288,256,224,192,160,128];
  var columnFallDepth=[0,0,0,0,0,0,0];
  late int playerColor;
  late int oppColor;
  late bool canPress=false;
  bool isSpacePressed=false;
  bool gameWon=false;
  bool gameend=false;
  bool reset=false;
  bool started=false;
  bool isAndroid = Platform.isAndroid;
  int winner = -1;
  late Arrow arrow;
  late WaitingMsg waitingMsg;
  late Coin previousCoin;
  Connect4Turnmsg turnmsg=Connect4Turnmsg();
  @override
  FutureOr<void> onLoad() async{
    waitingMsg=WaitingMsg();
    level=await TiledComponent.load('board.tmx', Vector2.all(32));
    add(level);
    levelFront=await TiledComponent.load('board_front.tmx', Vector2.all(32));
    add(levelFront);
    levelFront.priority = 2;
    add(waitingMsg);
    waitingMsg.priority = 3;
    previousCoin=Coin(cointPos: Vector2.zero(),coinColor: "red_coin",fallDepth: 0);
    previousCoin.isFalling=false;
    final spawnPointLayer =level.tileMap.getLayer<ObjectGroup>('test'); 
    for(final spawnPoint in spawnPointLayer!.objects){
          paths.add(spawnPoint);
    }
    arrow=Arrow(paths: paths);
    arrow.position = paths[3].position;
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
    }
    await setupRealtime();
    final gamestate = await supabase.from('connect_4_rooms').select('player1_id,player2_id,game_state,turn').eq('room_id',19667).maybeSingle();
    if(gamestate!['player1_id'] == null){
      await supabase.from('connect_4_rooms').update({'player1_id':playerId}).eq('room_id',19667);
      playerColor=0;
      oppColor=1;
    }else if(gamestate['player1_id'] != null && gamestate['player1_id'] !=playerId && gamestate['player2_id'] == null ){
      await supabase.from('connect_4_rooms').update({'player2_id':playerId,'game_state':"started",'board_state':playerPlacements}).eq('room_id',19667);
      playerColor=1;
      oppColor=0;
      remove(waitingMsg);
    }else if((gamestate['player1_id'] == playerId && gamestate['game_state'] == "p1_disconnected") ||
             (gamestate['player2_id'] == playerId && gamestate['game_state'] == "p2_disconnected")){
      if(gamestate['player1_id'] == playerId){
        playerColor=0;
        oppColor=1;
      }else{
        playerColor=1;
        oppColor=0;
      }
      if(gamestate['turn']!=playerColor){
        canPress=true;
        arrow.position = paths[3].position;
        if(!isAndroid){
          add(arrow);
        }else{
          addAll(darros);
        }
      }
      remove(waitingMsg);
      await loadGameState();
    }
    add(turnmsg);
    return super.onLoad();
  }

  Future<void> setupRealtime() async {
  channel = supabase
      .channel('public:connect_4_rooms') // This is your broadcast channel
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'connect_4_rooms',
        callback: (payload) {
          final newData = payload.newRecord;
          final oldData = payload.oldRecord;

          print("Realtime update received");
          print("New Record: $newData");
          print("Old Record: $oldData");

          if (newData['game_state'] == "started" && !started) {
            print("Game started");
            started = true;
            if (waitingMsg.isMounted) {
              remove(waitingMsg);
            }
            if (newData['player1_id'] == playerId) {
              canPress = true;
              arrow.position = paths[3].position;
              if(!isAndroid){
                add(arrow);
              }else{
                addAll(darros);
              }
            }
          } else if (oldData["game_state"] == "started" &&
              (newData["game_state"] == "p1_disconnected" ||
                  newData["game_state"] == "p2_disconnected")) {
            started = false;
            add(waitingMsg);
            print("Opponent disconnected");
          } else if ((oldData["game_state"] == "p1_disconnected" ||
                  oldData["game_state"] == "p2_disconnected") &&
              newData["game_state"] == "started") {
            started = true;
            print("Reconnected");
            if (waitingMsg.isMounted) {
              remove(waitingMsg);
            }
          } else if ((oldData["turn"] != newData["turn"])) {
            print("Turn changed");
            if(newData["turn"]!=null && newData["player_move"]!=null){
              final int playerMoved = newData["turn"] as int;
              final int playerMove = newData["player_move"] as int;
              final coin = Coin(cointPos: paths[playerMove].position,coinColor: coinColors[playerMoved],fallDepth: fallDepth[columnFallDepth[playerMove]]);
              coins.add(coin);
              playerPlacements[5-columnFallDepth[playerMove]][playerMove]=playerMoved;
              gameWon = _checkWin(5-columnFallDepth[playerMove],playerMove,playerMoved);
              if (gameWon) winner = playerMoved;
              columnFallDepth[playerMove] += 1;
              add(coin);
              previousCoin = coin;
              turnmsg.changeTurn((playerMoved==1)?0:1);
              if (playerMoved != playerColor) {
                canPress = true;
                if(!isAndroid){
                  add(arrow);
                }else{
                  addAll(darros);
                }
              }
            }
          }
        },
      );

  final status = await channel!.subscribe();
  print("📡 Channel status: $status");
}

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if(keysPressed.contains(LogicalKeyboardKey.space) && canPress){
      isSpacePressed=true;
    }
    if(keysPressed.contains(LogicalKeyboardKey.tab) && canPress && gameend){
      reset=true;
    }
    return super.onKeyEvent(event, keysPressed);
  }
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
        }
      }
    }
    super.onTapDown(event);
  }
  @override
  void update(double dt) async{
    if(!gameend && started){
      if(isSpacePressed && columnFallDepth[arrow.arrowCurrentPos]<6 && !arrow.hasMoved && !previousCoin.isFalling && arrow.canPress){
        if(!isAndroid){
          remove(arrow);
        }else{
          removeAll(darros);
          for(final drparrows in darros){
            drparrows.reset();
          }
        }
        canPress=false;
        isSpacePressed=false;
        await supabase.from('connect_4_rooms').update({'turn':playerColor,'player_move':arrow.arrowCurrentPos}).eq('room_id',19667);
        await supabase.from('connect_4_rooms').update({'board_state':playerPlacements}).eq('room_id',19667);
      }
      else if(!previousCoin.isFalling){
        if(gameWon){
          String wName;
          if(winner == 1){
            wName="yellow_win_msg";
          }else{
            wName="red_win_msg";
          }
          Winmsg msg=Winmsg(message: wName);
          await add(msg);
          this.msg.add(msg);
          gameend=true;
        }else{
          _checkDraw();
        }
      }
      if(arrow.hasMoved){
        isSpacePressed=false;
        arrow.hasMoved=false;
      }
    }
    super.update(dt);
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
  @override
  void onRemove() {
    if (channel != null) {
      Supabase.instance.client.removeChannel(channel!);
    }
    super.onRemove();
  }
  Future<void> loadGameState() async{
    final gamestate = await supabase.from('connect_4_rooms').select('turn,game_state,board_state').eq('room_id',19667).maybeSingle();
    playerPlacements = (gamestate!['board_state'] as List)
    .map<List<int>>((row) => (row as List).map<int>((e) => e ?? -1).toList())
    .toList();
    print(playerPlacements);
    Vector2 pos;
    for(int j=0;j<=6;j++){
      int i=5;
      while(i!=0){
        if(playerPlacements[i][j]!=-1){
          pos=Vector2(paths[j].x, paths[j].y+fallDepth[5-i]);
          Coin coin= Coin(cointPos: pos,coinColor: coinColors[playerPlacements[i][j]],fallDepth: 0);
          add(coin);
          coins.add(coin);
          columnFallDepth[j] += 1;
        }
        i--;
      }
    }
  }
}