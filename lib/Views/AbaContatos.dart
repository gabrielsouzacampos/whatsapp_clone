import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/Models/Conversa.dart';
import 'package:whatsapp/Models/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/routeGenerator.dart';

class AbaContatos extends StatefulWidget {
  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {
  String _idUsuarioLogado;
  String _emailUsuarioLogado;

  //Recupera os dados do usuario no firebase
  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuario = await auth.currentUser();
    _idUsuarioLogado = usuario.uid;
    _emailUsuarioLogado = usuario.email;
  }

  //Recupera os contatos do usuario
  Future<List<Usuario>> _recuperarContatos() async {
    Firestore db = Firestore.instance;
    QuerySnapshot querySnapshot =
        await db.collection("Usuarios").getDocuments();

    List<Usuario> listaUsuario = List();
    for (DocumentSnapshot item in querySnapshot.documents) {
      var dados = item.data;

      if(dados["email"] == _emailUsuarioLogado) continue;

      Usuario usuario = Usuario();
      usuario.email = dados["email"];
      usuario.nome = dados["nome"];
      usuario.urlImagem = dados["urlImagem"];
      usuario.idUsuario = item.documentID;
      listaUsuario.add(usuario);
    }

    return listaUsuario;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperarContatos(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: <Widget>[
                  Text("Carregando contatos"),
                  CircularProgressIndicator()
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey,
              ),
              itemCount: snapshot.data.length,
              itemBuilder: (_, indicie) {
                List<Usuario> listaItens = snapshot.data;
                Usuario usuario = listaItens[indicie];

                return ListTile(
                  onTap: (){
                    Navigator.pushNamed(
                      context, 
                      routeGenerator.rotaMensagens,
                      arguments: usuario
                    );
                  },
                  contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  leading: CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.grey,
                    backgroundImage: usuario.urlImagem != null ? NetworkImage(usuario.urlImagem)
                                        : null
                  ),
                  title: Text(
                    usuario.nome,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                );
              },
            );
            break;
          default:
        }
      },
    );
  }
}
