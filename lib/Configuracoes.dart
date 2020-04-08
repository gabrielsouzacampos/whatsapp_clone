import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Configuracoes extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController _controllerNome = TextEditingController();
  File _imagem;
  String _idUsuarioLogado;
  bool _subindoImagem = false;
  String _urlImagemRecuperada;

  //Metodo para recuperação da imagem com a galeria ou camera e seta a imagem no widget. 
  Future _recuperarImagem(String origemImagem) async{
    File _imagemSelecionada;
    switch (origemImagem) {
      case "Camera":
         _imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.camera);
        break;
      case "Galeria":
        _imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _imagem = _imagemSelecionada;
      if(_imagem != null){
        _subindoImagem = true;
        _uploadImagem();
      }
    });
  }

  //Realiza o upload da imagem no FirebaseStorage 
  Future _uploadImagem () async {
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = storage.ref()
      .child("perfil")
      .child(_idUsuarioLogado + ".jpg");
    
    StorageUploadTask task = arquivo.putFile(_imagem);

    task.events.listen(
      (StorageTaskEvent storageEvent) { 
        if(storageEvent.type == StorageTaskEventType.progress){
          setState(() {
            _subindoImagem = true;
          });
        }
        else if(storageEvent.type == StorageTaskEventType.success){
          setState(() {
            _subindoImagem = false;
          });
        }
      }
    );

    task.onComplete.then(
        (StorageTaskSnapshot snapshot) {
          _recuperarUrlImagem(snapshot);
        }
      );
  }

  //Recupera a URL da Imagem
  Future _recuperarUrlImagem (StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();
    _atualizarUrlImagemFirestore( url );

    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  //Atualiza a Url da imagem no Firebase
  _atualizarUrlImagemFirestore (String url){
    Firestore db = Firestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      "urlImagem": url
    };

    db.collection("Usuarios")
      .document(_idUsuarioLogado)
      .updateData(dadosAtualizar);
  }

  //Atualiza o nome no Firebase
  _atualizarNomeFirestore (){
    Firestore db = Firestore.instance;
    String nome = _controllerNome.text;

    Map<String, dynamic> dadosAtualizar = {
      "nome": nome
    };

    db.collection("Usuarios")
      .document(_idUsuarioLogado)
      .updateData(dadosAtualizar);
  }

  //Recupera os dados do usuario no firebase
  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuario = await auth.currentUser();
    _idUsuarioLogado = usuario.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection("Usuarios").document(_idUsuarioLogado).get();
     Map<String, dynamic> dadosUsuario = snapshot.data;
     _controllerNome.text = dadosUsuario["nome"];
     
     if(dadosUsuario["urlImagem"] != null){
       _urlImagemRecuperada = dadosUsuario["urlImagem"];
     }
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
      ),

      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                //Icone Carregamento
                Container(
                  child: _subindoImagem
                ? CircularProgressIndicator()
                : Container(),
                ),
                
                //Imagem do usuario
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.grey,
                  backgroundImage: _urlImagemRecuperada != null
                  ? NetworkImage(_urlImagemRecuperada) 
                  : null,
                ),

                //Botões 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //Botão Camera
                    FlatButton(
                      onPressed: (){
                        _recuperarImagem("Camera");
                      }, 
                      child: Text("Câmera"),
                    ), 
                    //Botão Galeria
                    FlatButton(
                      onPressed: (){
                        _recuperarImagem("Galeria");
                      }, 
                      child: Text("Galeria"),
                    ),                       
                  ],
                ),
              
                //Input do Nome
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Nome",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),

                //Botão Salvar
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                      child: Text(
                        "Salvar",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      color: Colors.green,
                      padding: EdgeInsetsDirectional.fromSTEB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {
                        _atualizarNomeFirestore();
                      }),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}