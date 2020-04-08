import 'package:flutter/material.dart';
import 'package:whatsapp/routeGenerator.dart';
import 'Login.dart';
import 'dart:io';

final ThemeData temaPadrao = ThemeData(
        primaryColor: Color(0xff075E54),
        accentColor: Color(0xff25D366),
      );

final ThemeData temaIOS = ThemeData(
        primaryColor: Colors.grey[200],
        accentColor: Color(0xff25D366),
      );

void main() {
  runApp(
    MaterialApp(
      home: Login(),
      theme: Platform.isIOS ? temaIOS : temaPadrao,
      initialRoute: "/",
      onGenerateRoute: routeGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
    )
  );
}