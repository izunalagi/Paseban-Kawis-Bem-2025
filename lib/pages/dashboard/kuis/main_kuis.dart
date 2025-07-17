import 'package:flutter/material.dart';

class QuizPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kuis'), centerTitle: true),
      body: Center(
        child: Text('Halo, ini kuis', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
