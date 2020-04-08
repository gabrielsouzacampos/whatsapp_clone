import 'package:cloud_firestore/cloud_firestore.dart';
class Conversa {
  
  String _nome;
  String _mensagem;
  String _urlImagem;
  String _idRemetente;
  String _idDestinatario;
  String _tipoMensagem;

  Conversa();

   Map<String, dynamic> toMap (){
    Map<String, dynamic> map = {
      "idRemetente": this.idRemetente,
      "idDestinatario" : this.idDestinatario,
      "nome" : this.nome,
      "mensagem" : this.mensagem,
      "urlImagem" : this.urlImagem,
      "tipoMensagem" : this.tipoMensagem
    };
    return map;
  }

  salvar() async {
    Firestore db = Firestore.instance;
    await db.collection("Conversas")
            .document(this.idRemetente)
            .collection("ultimaConversa")
            .document(this.idDestinatario)
            .setData(this.toMap());
  }

  String get idRemetente => _idRemetente;
  set idRemetente(String value){
    _idRemetente = value;
  }

  String get idDestinatario => _idDestinatario;
  set idDestinatario(String value){
    _idDestinatario = value;
  }

  String get tipoMensagem => _tipoMensagem;
  set tipoMensagem(String value){
    _tipoMensagem = value;
  }

  String get mensagem => _mensagem;
  set mensagem(String value){
    _mensagem = value;
  }

  String get urlImagem => _urlImagem;
  set urlImagem(String value){
    _urlImagem = value;
  }

  String get nome => _nome;
  set nome(String value){
    _nome = value;
  }
}