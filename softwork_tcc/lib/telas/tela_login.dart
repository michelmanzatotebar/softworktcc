import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/login_controller.dart';
import 'tela_cadastro.dart';
import 'tela_principal_cliente.dart';
import 'tela_principal_prestador.dart';

class TelaLogin extends StatefulWidget {
  @override
  _TelaLoginState createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final LoginController _loginController = LoginController();

  @override
  void initState() {
    super.initState();
    _configurarCallbacks();
    _loginController.verificarUsuarioLogado();
  }

  void _configurarCallbacks() {
    _loginController.setCallbacks(
      loadingCallback: (bool isLoading) {
        setState(() {});
      },
      messageCallback: (String message, bool isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
            duration: Duration(seconds: isSuccess ? 3 : 5),
          ),
        );
      },
      cadastroCallback: (String email, String nome, String uid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TelaCadastro(
              email: email,
              nome: nome,
              uid: uid,
            ),
          ),
        );
      },
      mainCallback: (Map<dynamic, dynamic> dadosUsuario, String cpfCnpj, bool tipoConta) {
        String nomeUsuario = dadosUsuario['nome'] as String;

        if (tipoConta) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => TelaPrincipalCliente(
                nomeUsuario: nomeUsuario,
                cpfCnpj: cpfCnpj,
              ),
            ),
                (Route<dynamic> route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => TelaPrincipalPrestador(
                nomeUsuario: nomeUsuario,
                cpfCnpj: cpfCnpj,
              ),
            ),
                (Route<dynamic> route) => false,
          );
        }
      },
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
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 42,
                      fontWeight: FontWeight.w500,
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
                  'Use sua conta Google para acessar',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),

                SizedBox(height: 60),

                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _loginController.isLoading ? null : _loginController.loginComGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _loginController.isLoading
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      'Entrar com o Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}