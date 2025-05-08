import 'package:connect_4/pages/signup_splash.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:lottie/lottie.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';
import 'package:flame/flame.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zbzoipcvwgpxhmrkpwlv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpiem9pcGN2d2dweGhtcmtwd2x2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM4NjMwNjMsImV4cCI6MjA1OTQzOTA2M30.hk8SNb0lCP10vVaDRd9MdV96O2eCM0zvN7NOauMhxPs',
  );
  runApp(MaterialApp(
    home: SignupPage(),
  ));
}

final supabase = Supabase.instance.client;

class SignupPage extends StatelessWidget {
  SignupPage({Key? key}) : super(key: key);
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final unameController = TextEditingController();
  final cpasswordController = TextEditingController();

  Future<String> signupManager(String email, String pwd, String cpwd, String uname) async{
    try {
        if(pwd.isEmpty) return 'pwe';
        if(pwd != cpwd) return 'pwnm';
        if(email.isEmpty) return 'eme';
        await supabase.from('users').insert({
          'user_mail':email,
          'user_name':uname,
          'user_pwd': pwd
        });
        print('successfully created user!');
        final uniqueId = await supabase.from('users').select('player_id').eq('user_mail', email).single();
        final plid = uniqueId['player_id'];
        print(plid);
        await supabase.from('logins').insert({'player_id': plid});
        return 'created';
    }
    catch(e){
      final dynamic error = e;
      print(e);
      print(error.code);
      if(error.code == '23505'){
        if(error.message.contains('user_mail')){
          return 'um';
        }
        else if(error.message.contains('user_name')){
          return 'up';
        }
        return 'uk';
      }
      return 'null';
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup to PixelVerse'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/lottie/signup_hand.json', repeat: true, height: 200),
                  Text('Welcome aboard!', style: TextStyle(fontFamily: 'Product Sans', fontSize: 23.0, fontWeight: FontWeight.bold)),
                  Text('Enter your details', style: TextStyle(fontFamily: 'Product Sans', fontSize: 23.0)),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter email ',
                    ),
                    controller: emailController,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter username (display name) ',
                    ),
                    controller: unameController,
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
                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Confirm password',
                    ),
                    controller: cpasswordController,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async{
                        final ret = await signupManager(emailController.text, passwordController.text, cpasswordController.text, unameController.text);
                          if(ret == 'uk'){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unknown error')));
                          }
                          else if(ret == 'eme'){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email is empty!')));
                          }
                          else if(ret == 'um'){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mail already exists! Login instead.')));
                          }
                          else if(ret == 'up'){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Player name is taken. Choose another.')));
                          }
                          else if(ret == 'null'){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error in creating user. Report this issue.')));
                          }
                          else if(ret == 'pwe'){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password is empty!')));
                          }
                          else if(ret == 'pwnm'){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Entered passwords do not match!')));
                          }
                          else{
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignupSplash(username: unameController.text,)));
                            Future.delayed(Duration(seconds: 4), () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          });
                          }
                      },
                      child: const Text('Sign up')
                    )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
