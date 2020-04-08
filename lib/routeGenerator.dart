import 'package:flutter/material.dart';
import 'package:whatsapp/Configuracoes.dart';
import 'package:whatsapp/Home.dart';
import 'package:whatsapp/Views/Mensagens.dart';
import 'Cadastro.dart';
import 'Login.dart';

class routeGenerator{

  static const rotaHome = "/home";
  static const rotaLogin = "/login";
  static const rotaCadastro = "/cadastro";
  static const rotaConfiguracoes = "/configuracoes";
  static const rotaMensagens = "/mensagens";
  
  //Configura as rotas
  static Route<dynamic> generateRoute(RouteSettings settings){

    final args = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => Login());
      case rotaLogin:
        return MaterialPageRoute(builder: (_) => Login());
      case rotaCadastro:
        return MaterialPageRoute(builder: (_) => Cadastro());
      case rotaHome:
        return MaterialPageRoute(builder: (_) => Home());
      case rotaConfiguracoes:
        return MaterialPageRoute(builder: (_) => Configuracoes());
      case rotaMensagens:
        return MaterialPageRoute(builder: (_) => Mensagens(args));
      default:
      _erroRota();
    }

  }

  //Em caso de Erro nas rotas exibe uma mensagem de erro
  static Route<dynamic> _erroRota(){
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(title: Text("Tela não encontrada!"),),
          body: Center(child: Text("Tela não encontrada!"),),
        );
      }
    );
  }

}