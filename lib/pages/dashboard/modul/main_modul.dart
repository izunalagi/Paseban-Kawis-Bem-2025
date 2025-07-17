import 'package:flutter/material.dart';

class ModulPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modul'), centerTitle: true),
      body: Center(
        child: Text('Halo, ini modul', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
