import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/Views/AbaContatos.dart';
import 'package:whatsapp/Views/AbaConversas.dart';
import 'package:whatsapp/routeGenerator.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  String _emailUsuario = "";
  TabController _tabController;
  List<String> _itensMenu = [
    "Configurações",
    "Sair"
  ];

  Future _recuperarDadosUsuario () async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    setState(() {
      _emailUsuario = usuarioLogado.email;
    });
  }

   //Verifica se o Usuario está logado, em sucesso vai para a Home()
  Future _verificaUsuarioLogado () async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    //auth.signOut();
    if(usuarioLogado == null){
      Navigator.popAndPushNamed(context, routeGenerator.rotaLogin);
    }
  }

  @override
  void initState() {
    super.initState();
    _verificaUsuarioLogado();
    _recuperarDadosUsuario();
    _tabController = TabController(
      length: 2, 
      vsync: this
    );
  }

  _escolhaMenuItem(String itemEscolhido){
    switch (itemEscolhido) {
      case "Configurações":
         Navigator.pushNamed(context, routeGenerator.rotaConfiguracoes);
        break;
      case "Sair":
        _deslogarUsuario();
        break;
    }
  }

  _deslogarUsuario () async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();

    Navigator.popAndPushNamed(context, routeGenerator.rotaLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WhatsApp"),
        elevation: Platform.isIOS ? 0 : 4,
        bottom: TabBar(
          indicatorWeight: 4,
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
          controller: _tabController,
          indicatorColor: Platform.isIOS ? Colors.grey[400] : Colors.white,
          tabs: <Widget>[
            Tab(text: "Conversas"),
            Tab(text: "Contatos",)
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context){
              return _itensMenu.map(
                (String item){
                  return PopupMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                } 
              ).toList();
            },
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          AbaConversas(),
          AbaContatos()
        ],
      )
    );
  }
}