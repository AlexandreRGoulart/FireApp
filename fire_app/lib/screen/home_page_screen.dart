import 'package:fire_app/screen/show_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:fire_app/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fire_app/database/database_service.dart';


class HomePageScreen extends StatelessWidget {
  HomePageScreen({super.key});

  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().SignOut();
  }

  Widget _title(){
    return const Text('FireApp Login');
  }

  Widget _userUid(){
    return Text(user?.email ?? 'User email');
  }

  Widget _signOutButton(){
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out')
    );
  }

   Widget _criarDados(){
        return ElevatedButton(
          onPressed:() async {
            await DatabaseService().create(path: 'data1', data:"{'name':'Flutter pro'}");
          },
          child: const Text('Criar dados')
        );
      }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _title(),
      ),

      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userUid(),
            _signOutButton(),
            _criarDados(),
            ElevatedButton(
              onPressed:(){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShowLocationScreen()),
                );
            },
            child: const Text('Abrir Mapa'),
            ),
          ]
        ),
      )
    );
  }
}