import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'tela_cadastro.dart';

class TelaLogin extends StatefulWidget {
  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _verificarUsuarioLogado();
  }

  Future<void> _verificarUsuarioLogado() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      print("estava logado: ${currentUser.email}");
      print("deslogando");
      await _auth.signOut();
      await _googleSignIn.signOut();
    }
  }

  Future<void> _loginComGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print("Iniciando login com Google...");

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print("GoogleSignInAccount obtido: ${googleUser?.email}");

      if (googleUser == null) {
        print("Login cancelado pelo usuário");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print("Obtendo autenticação...");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print("Autenticação obtida. AccessToken existe: ${googleAuth.accessToken != null}");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("Fazendo login no Firebase");
      UserCredential? userCredential;

      try {
        userCredential = await _auth.signInWithCredential(credential);
      } catch (authError) {
        print("Erro no signInWithCredential: $authError");
        if (_auth.currentUser != null) {
          print("Usuário já está logado, usando currentUser");
          await _verificarCadastroCompleto(_auth.currentUser!);
          return;
        }
        throw authError;
      }

      if (userCredential.user != null) {
        print("Login Google realizado com sucesso: ${userCredential.user?.email}");
        print("Nome do usuário: ${userCredential.user?.displayName}");
        print("ID do usuário: ${userCredential.user?.uid}");

        await _verificarCadastroCompleto(userCredential.user!);
      } else {
        throw Exception("Usuário nulo após login");
      }

    } catch (e) {
      print("Erro detalhado ao fazer login com Google: $e");
      print("Tipo do erro: ${e.runtimeType}");

      String mensagemErro = 'Erro ao fazer login com Google';

      if (e.toString().contains('PlatformException')) {
        mensagemErro = 'Erro de configuração';
      } else if (e.toString().contains('network')) {
        mensagemErro = 'Erro de conexão';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagemErro),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verificarCadastroCompleto(User user) async {
    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref();

      final snapshot = await ref.child('usuarios').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> usuarios = snapshot.value as Map<dynamic, dynamic>;

        bool cadastroCompleto = false;
        String? cpfCnpjUsuario;

        for (var entry in usuarios.entries) {
          var dadosUsuario = entry.value as Map<dynamic, dynamic>;

          if (dadosUsuario['email'] == user.email) {
            if (dadosUsuario['nome'] != null &&
                dadosUsuario['logradouro'] != null &&
                dadosUsuario['cep'] != null &&
                dadosUsuario['tipoConta'] != null) {
              cadastroCompleto = true;
              cpfCnpjUsuario = entry.key;
              break;
            }
          }
        }

        if (cadastroCompleto && cpfCnpjUsuario != null) {
          print("Usuário já possui cadastro completo. CPF/CNPJ: $cpfCnpjUsuario");

          // Navegar para a tela principal do app


          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Seja Bem vindo!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _navegarParaCadastro(user);
        }
      } else {
        _navegarParaCadastro(user);
      }
    } catch (e) {
      print("Erro ao verificar cadastro: $e");
      _navegarParaCadastro(user);
    }
  }

  void _navegarParaCadastro(User user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TelaCadastro(
          email: user.email ?? '',
          nome: user.displayName ?? '',
          uid: user.uid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.red[400]!, width: 2),
                      left: BorderSide(color: Colors.red[400]!, width: 2),
                    ),
                  ),
                  child: Text(
                    'SoftWork',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                      color: Colors.black87,
                    ),
                  ),
                ),

                SizedBox(height: 80),

                Text(
                  'Bem vindo!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  'Faça login para continuar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: 60),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loginComGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40),

                Text(
                  'Use sua conta Google para acessar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}