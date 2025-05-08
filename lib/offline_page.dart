import 'dart:io';
import 'package:connect_4/connect_4.dart';
import 'package:connect_4/pixel_adventure.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:connect_4/reversi.dart';
bool isAndroid = Platform.isAndroid;
class OfflinePixelGamePage extends StatefulWidget {
  @override
  _PixelGamePageState createState() => _PixelGamePageState();
}

class _PixelGamePageState extends State<OfflinePixelGamePage> with WidgetsBindingObserver {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            height: 740,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/Background/HomeBackground.png'), fit: BoxFit.cover),
            ),
          child: Center(
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
                    (isAndroid)?'Scroll down to play':'Tap on any game to start!',
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
                              MaterialPageRoute(builder: (context) => GameScreen(game: Connect4(mode:"offline"))),
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
          )
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
      );
  }
}

class GameScreen extends StatelessWidget {
  final FlameGame game;
  GameScreen({required this.game});
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          GameWidget(game: game),
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 32, color: Colors.white),
              onPressed: () async {
                  Navigator.pop(context);
              },
            ),
          ),
        ],
    );
  }
}