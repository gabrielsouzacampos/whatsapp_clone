import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/routeGenerator.dart';
import 'Home.dart';
import 'Models/Usuario.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {

  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = '';

  //Valida os campos e caso tenha algum erro exibe uma mensagem e em caso de sucesso entra no metodo _cadastroUsuario
  _validarCampos(){
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if(nome.isNotEmpty){
      if( email.isNotEmpty && email.contains("@")){
        if(senha.isNotEmpty && senha.length >= 6){
          setState(() {
            _mensagemErro = "";
          });

          Usuario usuario = Usuario();
          usuario.nome = nome;
          usuario.email = email;
          usuario.senha = senha;

          _cadastrarUsuario(usuario);
        }
        else{
          setState(() {
        _mensagemErro = "Preencha a senha (deve ter 6 ou mais caracteres).";
      });
        }
      }
      else{
        setState(() {
        _mensagemErro = "Preencha o email utlizando @.";
      });
      }
    }
    else{
      setState(() {
        _mensagemErro = "Nome precisa ter mais que três caracteres.";
      });
    }

  }
  
  //Cadastra o usuario no FirebaseAuth e redireciona o usuario para a Home()
  _cadastrarUsuario(Usuario usuario){
    FirebaseAuth auth = FirebaseAuth.instance;

    auth.createUserWithEmailAndPassword(
      email: usuario.email, 
      password: usuario.senha
    ).then(
      (firebaseUser) {
        Firestore db = Firestore.instance;
        db.collection("Usuarios").document(firebaseUser.user.uid).setData(usuario.toMap());

        Navigator.pushNamedAndRemoveUntil(context, routeGenerator.rotaHome, (_) => false);
      }
    ).catchError((erro){
      setState(() {
        _mensagemErro = "Erro ao cadastrar, verifique os campos e tente novamente";
      });
    });


  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),
      body: Container(
        decoration: BoxDecoration(color: Color(0xff075E54)),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                //Logo
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset("imagens/usuario.png", width: 200, height: 150,),
                ),

                //Input do Nome
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    autofocus: true,
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

                //Input do E-mail
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEmail,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "E-mail",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32))),
                  ),
                ),

                //Input da Senha
                TextField(
                  controller: _controllerSenha,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32))),
                ),

                //Botão de Cadastro
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                      child: Text(
                        "Cadastrar",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      color: Colors.green,
                      padding: EdgeInsetsDirectional.fromSTEB(32, 16, 32, 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {
                        _validarCampos();
                      }),
                ),

                //Mensagem de Erro
                Center(
                  child: Text(
                    _mensagemErro,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
