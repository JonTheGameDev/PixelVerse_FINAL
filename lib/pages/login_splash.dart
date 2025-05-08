import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: LoginSplash(username: null,)
  ));
}

class LoginSplash extends StatelessWidget{
  LoginSplash({required this.username});
  final username;
  @override
  Widget build(BuildContext context){
      
      return Scaffold(appBar: null, 
                      body: Center(child: 
                      Column(children: [Lottie.asset('assets/lottie/success.json', 
                                                      repeat: false,
                                                      width: 600),
                                        Text('Logged in as $username🔥\nTaking you home...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30))])));
  }
}