import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/routeGenerator.dart';
import 'Cadastro.dart';
import 'Home.dart';
import 'Models/Usuario.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  String _mensagemErro = '';

  //Valida os campos de Login e em caso de erro exibe mensagem e em caso de sucesso vai para o metodo de _logarUsuario()
  _validarCampos(){
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

      if( email.isNotEmpty && email.contains("@")){
        if(senha.isNotEmpty){
          setState(() {
            _mensagemErro = "";
          });

          Usuario usuario = Usuario();
          usuario.email = email;
          usuario.senha = senha;

          _logarUsuario(usuario);
        }
        else{
          setState(() {
        _mensagemErro = "Preencha a senha";
      });
        }
      }
      else{
        setState(() {
        _mensagemErro = "Preencha o email utlizando @.";
      });
      }
  }

  //Tenta logar no FirebaseAuth
  _logarUsuario(Usuario usuario){
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(
      email: usuario.email, 
      password: usuario.senha
    ).then(
      (firebaseUser){
        Navigator.popAndPushNamed(context, routeGenerator.rotaHome);
      }
    )
    .catchError(
      (error){
        setState(() {
          _mensagemErro = "Erro ao autenticar o usuario, verifique os campos e tente novamente.";
        });
      }
    );
  }
  
  //Verifica se o Usuario está logado, em sucesso vai para a Home()
  Future _verificaUsuarioLogado () async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    //auth.signOut();
    if(usuarioLogado != null){
      Navigator.popAndPushNamed(context, routeGenerator.rotaHome);
    }
  }

  @override
  void initState() {
    _verificaUsuarioLogado();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: Image.asset(
                    "imagens/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),

                //Input do E-mail
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerEmail,
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
                  obscureText: true,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32))),
                ),

                //Botão de Entrada
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: RaisedButton(
                      child: Text(
                        "Entrar",
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

                //Texto de novo cadastro
                Center(
                  child: GestureDetector(
                    child: Text(
                      "Não tem conta? cadastre-se!",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Cadastro(),
                          ));
                    },
                  ),
                ),

                //mensagem de erro
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      _mensagemErro,
                      style: TextStyle(color: Colors.red, fontSize: 20),
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