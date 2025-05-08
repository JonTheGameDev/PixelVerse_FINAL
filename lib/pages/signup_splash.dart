import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: SignupSplash(username: null,)
  ));
}

class SignupSplash extends StatelessWidget{
  SignupSplash({required this.username});
  final username;
  @override
  Widget build(BuildContext context){
      
      return Scaffold(appBar: null, 
                      body: Center(child: 
                      Column(children: [Lottie.asset('assets/lottie/signup.json', 
                                                      repeat: false,
                                                      width: 300),
                                        Text('Welcome to the game, $username🔥\n', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30))])));

  }
}