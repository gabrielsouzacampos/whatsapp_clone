import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/Models/Conversa.dart';
import 'package:whatsapp/Models/Mensagem.dart';
import 'package:whatsapp/Models/Usuario.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class Mensagens extends StatefulWidget {
  Usuario contato;
  Mensagens(this.contato);
  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  TextEditingController _controllerMensagem = TextEditingController();
  String _idUsuarioLogado;
  String _idUsuarioDestinatario;
  String _urlImagemRecuperada;
  Firestore db = Firestore.instance;
  File _imagem;
  bool _subindoImagem = false;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();
  //Recupera os dados do usuario no firebase
  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuario = await auth.currentUser();
    _idUsuarioLogado = usuario.uid;
    _idUsuarioDestinatario = widget.contato.idUsuario;
    _adicionarListenerMensagens();
  }

  //Verifica a mensagem que sera enviada
  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";
      mensagem.data = DateTime.now().toString();

      //salvando o remetente
      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

      //salvando para o destinatario
      _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

      //salvando a conversa
    _salvarConversa(mensagem);
    }
  }

  //Salva mensagem no Firestore
  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    await db
        .collection("Mensagens")
        .document(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    _controllerMensagem.clear();
  }

  //Envia uma imagem para o firebase
  _enviarFoto() async {

    File imagemSelecionada;
    imagemSelecionada = await ImagePicker.pickImage(source: ImageSource.gallery);

    _subindoImagem = true;
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("mensagens")
        .child( _idUsuarioLogado )
        .child( nomeImagem + ".jpg");

    //Upload da imagem
    StorageUploadTask task = arquivo.putFile( imagemSelecionada );

    //Controlar progresso do upload
    task.events.listen((StorageTaskEvent storageEvent){

      if( storageEvent.type == StorageTaskEventType.progress ){
        setState(() {
          _subindoImagem = true;
        });
      }else if( storageEvent.type == StorageTaskEventType.success ){
        setState(() {
          _subindoImagem = false;
        });
      }

    });

    //Recuperar url da imagem
    task.onComplete.then((StorageTaskSnapshot snapshot){
      _recuperarUrlImagem(snapshot);
    });

  }

  //Recupera a URL da Imagem
  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    Mensagem mensagem = Mensagem();
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.tipo = "imagem";
    mensagem.data = DateTime.now().toString();

    //salvando o remetente
    _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

    //salvando para o destinatario
    _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

    //salvando a conversa
    _salvarConversa(mensagem);
  }

  //Salva conversas do destinatario e do remetente
  _salvarConversa(Mensagem msg) async {
    Conversa conversaRemetente = Conversa();
    conversaRemetente.idRemetente = _idUsuarioLogado;
    conversaRemetente.idDestinatario = _idUsuarioDestinatario;
    conversaRemetente.mensagem = msg.mensagem;
    conversaRemetente.nome = widget.contato.nome;
    conversaRemetente.urlImagem = widget.contato.urlImagem;
    conversaRemetente.tipoMensagem = msg.tipo;
    conversaRemetente.salvar();

    Conversa conversaDestinatario = Conversa();
    conversaDestinatario.idRemetente = _idUsuarioDestinatario;
    conversaDestinatario.idDestinatario = _idUsuarioLogado;
    conversaDestinatario.mensagem = msg.mensagem;
    conversaDestinatario.nome = widget.contato.nome;
    conversaDestinatario.urlImagem = widget.contato.urlImagem;
    conversaDestinatario.tipoMensagem = msg.tipo;
    conversaDestinatario.salvar();
  }

  Stream<QuerySnapshot> _adicionarListenerMensagens(){

    final stream = db
            .collection("Mensagens")
            .document(_idUsuarioLogado)
            .collection(_idUsuarioDestinatario)
            .orderBy('data', descending: false)
            .snapshots();

    stream.listen((dados){
      _controller.add( dados );
      Timer(Duration(seconds: 1), (){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });

  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          //TextField
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                  hintText: "Digite uma mensagem",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32)),

                  //Enviar Foto
                  prefixIcon:
                      _subindoImagem
                        ? CircularProgressIndicator()
                        : IconButton(icon: Icon(Icons.camera_alt),onPressed: _enviarFoto),
                ),
              ),
            ),
          ),

          //Botão de Enviar
          Platform.isIOS 
          ? CupertinoButton(
            child: Text("Enviar"),
            onPressed: _enviarMensagem,
          )
          : FloatingActionButton(
              backgroundColor: Color(0xff075E54),
              child: Icon(
                Icons.send,
              color: Colors.white,
              ),
              mini: true,
              onPressed: _enviarMensagem,
          ) 
        ],
      ),
    );

    var stream = StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  children: <Widget>[
                    Text("Carregando mensagens"),
                    CircularProgressIndicator()
                  ],
                ),
              );
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              QuerySnapshot querySnapshot = snapshot.data;

              if (snapshot.hasError) {
                return Expanded(
                  child: Text("Erro ao busacar dados"),
                );
              } else {
                return Expanded(
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: querySnapshot.documents.length,
                      itemBuilder: (context, indicie) {
                        List<DocumentSnapshot> mensagensRecebida =
                            querySnapshot.documents.toList();
                        DocumentSnapshot item = mensagensRecebida[indicie];

                        double larguraContainer =
                            MediaQuery.of(context).size.width * 0.8;

                        Alignment alinhamento = Alignment.centerRight;
                        Color cor = Color(0xffd2ffa5);

                        if (_idUsuarioLogado != item["idUsuario"]) {
                          alinhamento = Alignment.centerLeft;
                          cor = Colors.white;
                        }

                        return Align(
                          alignment: alinhamento,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: Container(
                              width: larguraContainer,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: cor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: item["tipo"] == "texto" 
                              ? Text(
                                item["mensagem"],
                                style: TextStyle(fontSize: 18),
                              )
                              : Image.network(item["urlImagem"]),
                            ),
                          ),
                        );
                      }),
                );
              }
              break;
          }
        });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.contato.urlImagem != null
                    ? NetworkImage(widget.contato.urlImagem)
                    : null),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(widget.contato.nome),
            )
          ],
        ),
      ),
      body: Container(
        //Imagem de Fundo
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("imagens/fundo.png"), fit: BoxFit.cover)),

        child: SafeArea(
            child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              //lisview
              stream,
              //caixa de mensagem
              caixaMensagem,
            ],
          ),
        )),
      ),
    );
  }
}