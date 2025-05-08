import 'package:connect_4/gamepage.dart';
import 'package:connect_4/signup.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:lottie/lottie.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
//import 'package:first_app/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';
import 'package:flame/flame.dart';
import 'package:connect_4/pages/login_splash.dart';

bool isloggedIn=false;
String playerid="";
class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Future<String> loginManager(String email, String pwd) async{
    print('Email: '+email);
    print('Pwd: '+pwd);
    try {
        final uname = await supabase.from('users').select('user_name').eq('user_mail',email).eq('user_pwd', pwd).single();
        return uname['user_name'];
    }
    catch(e){
      return 'null';
    }
  }
  Future<String> isLoggedIn(String playerID) async{
    try {
        final uname = await supabase.from('logins').select('logged_in').eq('player_id',playerID).single();
        if(uname['logged_in']){
          return "Yes";
        }
        else{
          return "No";
        }
    }
    catch(e){
      return 'null';
    }
  }
  Future<String> getPlayerID(String email, String pwd) async{
    try {
        final uname = await supabase.from('users').select('player_id').eq('user_mail',email).eq('user_pwd', pwd).single();
        return uname['player_id'];
    }
    catch(e){
      return 'null';
    }
  }
  Future<void> updateLoggedIn(String playerId) async {
  try {
    final response = await supabase
    .from('logins')
    .update({'logged_in':true})
    .eq('player_id', playerId)
    .single();
    if (response == null) {
      print("No matching player found.");
    }
  } catch (e) {
    print("An error occurred: $e");
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to PixelVerse'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset('assets/lottie/login.json', repeat: true, width: 160),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontSize: 23.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your login details',
                    style: TextStyle(
                      fontFamily: 'Product Sans',
                      fontSize: 23.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter email',
                    ),
                    controller: emailController,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter password',
                    ),
                    controller: passwordController,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final usname = await loginManager(emailController.text, passwordController.text);
                            if (usname == 'null') {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid username or password!')));
                              return;
                            }
                            final playerID = await getPlayerID(emailController.text, passwordController.text);
                            final loggedIn = await isLoggedIn(playerID);
                            if (loggedIn == "Yes") {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User is already online in another window or device')));
                            } else {
                              await updateLoggedIn(playerID);
                              playerid = playerID;
                              isloggedIn = true;
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => LoginSplash(username: usname),
                              ));

                              Future.delayed(Duration(seconds: 4), () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PixelGamePage(PlayerID: playerID),
                                  ),
                                );
                              });
                            }
                          },
                          child: const Text('Login'),
                        ),
                        const SizedBox(width: 16),
                        Text('New here?'),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupPage()),
                            );
                          },
                          child: const Text('Sign up'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

