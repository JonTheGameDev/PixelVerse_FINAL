import 'package:connect_4/connect4_components/roomjoin.dart';
import 'package:connect_4/connect_4.dart';
import 'package:connect_4/login.dart';
import 'package:connect_4/pixel_adventure.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:connect_4/reversi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

ThemeData light = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.cyan,
);
ThemeData dark = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.purple,
);

class PixelGamePage extends StatefulWidget {
  final String PlayerID;
  PixelGamePage({required this.PlayerID});
  @override
  _PixelGamePageState createState() => _PixelGamePageState();
}

class _PixelGamePageState extends State<PixelGamePage> with WidgetsBindingObserver {
  final supabase = Supabase.instance.client;

  Future<void> logout() async {
    try {
      await supabase
          .from('logins')
          .update({'logged_in': false})
          .eq('player_id', widget.PlayerID);
    } catch (e) {
      print("Logout error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      logout();
    }
  }

  Widget buildGameCard({
    required Color backgroundColor,
    required String imagePath,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onLaunch,
  }) {
    return SizedBox(
      width: 280,
      child: Card(
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100,
              color: backgroundColor,
              child: Center(
                child: Image.asset(imagePath, fit: BoxFit.fitWidth),
              ),
            ),
            ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: Text(subtitle),
              dense: true,
              visualDensity: VisualDensity.compact,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(child: Text('Launch'), onPressed: onLaunch),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _showRoomIdDialog(BuildContext context) {
    final TextEditingController roomIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Room ID'),
        content: TextField(
          controller: roomIdController,
          decoration: InputDecoration(
            hintText: 'Room ID',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              print('Cancelled entering room ID');
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              print('Entered Room ID: ${roomIdController.text}');
              // Add your join logic here
            },
            child: Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showChoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width * 0.8,
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose an option',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        print('Create Room selected');
                      },
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Create Room',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop(); // Close first dialog
                        _showRoomIdDialog(context);   // Show second dialog
                      },
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Join Room',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await logout();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Container(child: SizedBox(child: Image.asset('assets/images/PixelVerse/PixelVerse-red.png'),height: 100), color: Color.fromARGB(255,255,87,87), width: 2000),
          backgroundColor: Color.fromARGB(255,255,87,87),
          foregroundColor: Colors.white,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await logout();
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            height: 740,
            width: 2000,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/Background/HomeBackground.png'), fit: BoxFit.cover),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to the PixelVerse!',
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Tap on any game to start!',
                    style: TextStyle(fontFamily: 'Product Sans', fontSize: 20.0),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    height: 215,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          buildGameCard(
                            backgroundColor: Color.fromARGB(255,94, 236, 235),
                            imagePath: 'assets/images/Thumbnails/Reversi.png',
                            title: 'Reversi',
                            subtitle: 'A classic game of strategy',
                            icon: Icons.games,
                            onLaunch: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GameScreen(game: Reversi())),
                            ),
                          ),
                          buildGameCard(
                            backgroundColor: Color.fromARGB(255,97, 41, 181),
                            imagePath: 'assets/images/Thumbnails/Connect4.png',
                            title: 'Connect 4',
                            subtitle: 'Get 4 coins together, win!',
                            icon: Icons.grid_on,
                            onLaunch: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GameScreen(game: Connect4(mode: "online"))),
                            ),
                          ),
                          buildGameCard(
                            
                            backgroundColor: Color.fromARGB(255,33, 31, 48),
                            imagePath: 'assets/images/Thumbnails/Platformer.png',
                            title: 'Platformer',
                            subtitle: 'Run, collect, dodge.',
                            icon: Icons.gesture,
                            onLaunch: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GameScreen(game: PixelAdventure())),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Text('?'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('About PixelVerse'),
                  content: Text('PixelVerse is a collection of online/offline multiplayer games.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  final FlameGame game;
  GameScreen({required this.game});

  final supabase = Supabase.instance.client;
  final int roomId = 19667;

  Future<bool> onWillPopHandler(BuildContext context) async {
    print("Exit attempt detected!");
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Exit Game?"),
        content: Text("Are you sure you want to leave the game?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if(game.runtimeType.toString()=="Connect4"){
                final gamestate = await supabase
                    .from('connect_4_rooms')
                    .select('player1_id,player2_id,game_state')
                    .eq('room_id', roomId)
                    .maybeSingle();

                if (gamestate != null) {
                  if ((gamestate['player1_id'] == playerid &&
                          gamestate['game_state'] == "p2_disconnected") ||
                      (gamestate['player2_id'] == playerid &&
                          gamestate['game_state'] == "p1_disconnected") ||
                      (gamestate['player1_id'] == playerid && gamestate['player2_id'] == null &&
                          gamestate['game_state'] == "p1_disconnected")) {
                    await supabase.from('connect_4_rooms').update({
                      'player1_id': null,
                      'player2_id': null,
                      'turn': null,
                      'player_move': null,
                      'game_state': null,
                      'board_state': null
                    }).eq('room_id', roomId);
                  } else if (gamestate['player1_id'] == playerid) {
                    await supabase.from('connect_4_rooms').update({
                      'game_state': "p1_disconnected"
                    }).eq('room_id', roomId);
                  } else if (gamestate['player2_id'] == playerid) {
                    await supabase.from('connect_4_rooms').update({
                      'game_state': "p2_disconnected"
                    }).eq('room_id', roomId);
                  }
                }
              }
              Navigator.of(context).pop(true); // Allow exit
            },
            child: Text("Exit"),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onWillPopHandler(context),
      child: Stack(
        children: [
          GameWidget(game: game),
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 32, color: Colors.white),
              onPressed: () async {
                if (await onWillPopHandler(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}