# Whatsapp_Clone
Este projeto foi desenvolvido com o intuito educacional, onde ilustra a estrutura de projeto utilizado pela gigante Whatsapp. Sendo simulado com a utilização das tecnologias Flutter e Firebase.

## Começando
Para a execução deste projeto, será necessário a instalação do [Flutter](https://flutter.dev/docs/get-started/install) e a configuração do projeto no [Firebase](https://medium.com/@engapplabs/como-implementar-firebase-à-sua-aplicação-em-flutter-42e20b1b4a5d).

## Desenvolvimento
Para iniciar o desenvolvimento, é necessário somente clonar o projeto do Github num diretório de sua prefêrencia e abri-lo ne um editor de texto também de sua prefêrencia.

```shell
cd "diretorio de sua preferencia"
git clone https://github.com/gabrielsouzacampos/whatsapp_clone.git
```

## Features
Como já foi dito o projeto foi utilizado com Flutter e Firebase, nesta seção irei especificar as bibliotecas e funcionalidades de cada no desenvolvimento do projeto. Para o 
desenvolvimento com o Flutter foi utilizado as seguintes bibliotecas:

- [Cupertino_icons](https://pub.dev/packages/cupertino_icons): Está biblioteca foi utilizada na versão 0.1.3 para a definição de icones no aplicativo.
- [Image_picker](https://pub.dev/packages/image_picker): Está biblioteca foi utilizada na versão 0.6.4 para escolher fotos da galeria e tirar novas fotos com a camera do aparelho.
- [firebase_core](https://pub.dev/packages/firebase_core): Está biblioteca foi utilizada na versão 0.4.4+3 para utilizar a API do Firebase Core, e assim ser possivel conectar com suas funcionalidades.
- [firebase_auth](https://pub.dev/packages/firebase_auth): Está biblioteca foi utilizada na versão 0.15.5+3 para utilizar a funcionalidade do Firebase Auth.
- [firebase_storage](https://pub.dev/packages/firebase_storage): Está biblioteca foi utilizada na versão 3.1.3 para utilizar a funcionalidade do Firebase Storage.
- [cloud_firestore](https://pub.dev/packages/cloud_firestore): Está biblioteca foi utilizada na versão 0.13.4+2 para utilizar a funcionalidade do Cloud Firestore (banco de dados recomendado pelo Firebase).

Já as funcionalidades do Firebase utilizadas foram:
- [Firebase Authentication](https://firebase.google.com/docs/auth): Solução completa de autenticação de usuarios, compativel com contas de e-mail/senha, autenticação por telefone, login do Google, Twitter, Facebook, GitHub e outros.
- [Cloud Storage](https://firebase.google.com/docs/storage): Solução completa para o armazenamento e disponibilidade do conteúdo gerado pelo usuário, como fotos ou vídeos, com  facilidade e rapidez.
- [Cloud Firestore](https://firebase.google.com/docs/firestore): Banco de dados de documentos NoSQL que permite armazenar, sincronizar e consultar dados facilmente para seus apps para dispositivos móveis e da Web, em escala global.
