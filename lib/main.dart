import 'package:connect_4/offline_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:connect_4/login.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zbzoipcvwgpxhmrkpwlv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpiem9pcGN2d2dweGhtcmtwd2x2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM4NjMwNjMsImV4cCI6MjA1OTQzOTA2M30.hk8SNb0lCP10vVaDRd9MdV96O2eCM0zvN7NOauMhxPs',
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_) {
    runApp(MaterialApp(home: LandingPage()));
  });
  
}
class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    return Scaffold(
      backgroundColor: const Color.fromARGB(229, 255, 255, 255),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: InkWell(
                splashColor: Colors.lightBlueAccent,
                hoverColor: Colors.teal,
                highlightColor: Colors.grey,
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => OfflinePixelGamePage()));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(20, 255, 255, 255),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.blueGrey, width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset('assets/lottie/singleplayer.json', width: 200),
                        SizedBox(height: 10),
                        Text(
                          'Single player mode (limited functionality)',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 30,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: InkWell(
                splashColor: Colors.lightGreen,
                hoverColor: Colors.green,
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(20, 255, 255, 255),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset('assets/lottie/multiplayer.json'),
                        SizedBox(height: 10),
                        Text(
                          'Multiplayer mode (network needed)',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 30,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
