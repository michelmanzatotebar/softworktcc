import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Function(bool)? onLoadingChanged;
  Function(String, bool)? onShowMessage;
  Function(String, String, String)? onNavigateToCadastro;
  Function(Map<dynamic, dynamic>, String, bool)? onNavigateToMain;

  void setCallbacks({
    Function(bool)? loadingCallback,
    Function(String, bool)? messageCallback,
    Function(String, String, String)? cadastroCallback,
    Function(Map<dynamic, dynamic>, String, bool)? mainCallback,
  }) {
    onLoadingChanged = loadingCallback;
    onShowMessage = messageCallback;
    onNavigateToCadastro = cadastroCallback;
    onNavigateToMain = mainCallback;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    onLoadingChanged?.call(_isLoading);
  }

  Future<void> verificarUsuarioLogado() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        print("estava logado: ${currentUser.email}");
        print("deslogando");

        await Future.wait([
          _auth.signOut(),
          _googleSignIn.signOut(),
        ]).timeout(Duration(seconds: 10));

        print("Logout concluído com sucesso");
      }
    } catch (e) {
      print("Erro durante verificação/logout: $e");
    }
  }

  Future<void> loginComGoogle() async {
    _setLoading(true);

    try {
      print("Iniciando login com Google...");

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print("GoogleSignInAccount obtido: ${googleUser?.email}");

      if (googleUser == null) {
        print("Login cancelado pelo usuário");
        _setLoading(false);
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

      onShowMessage?.call(mensagemErro, false);
    } finally {
      _setLoading(false);
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
        Map<dynamic, dynamic>? dadosUsuario;

        for (var entry in usuarios.entries) {
          var dados = entry.value as Map<dynamic, dynamic>;

          if (dados['email'] == user.email) {
            if (dados['nome'] != null &&
                dados['logradouro'] != null &&
                dados['cep'] != null &&
                dados['tipoConta'] != null) {
              cadastroCompleto = true;
              cpfCnpjUsuario = entry.key;
              dadosUsuario = dados;
              break;
            }
          }
        }

        if (cadastroCompleto && cpfCnpjUsuario != null && dadosUsuario != null) {
          print("Usuário já possui cadastro completo. CPF/CNPJ: $cpfCnpjUsuario");
          print("Tipo de conta: ${dadosUsuario['tipoConta']}");

          await _redirecionarParaTelaPrincipal(dadosUsuario, cpfCnpjUsuario);
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

  Future<void> _redirecionarParaTelaPrincipal(Map<dynamic, dynamic> dadosUsuario, String cpfCnpj) async {
    bool tipoConta = dadosUsuario['tipoConta'] as bool;

    if (tipoConta) {
      print("Redirecionando para tela principal do CLIENTE");
    } else {
      print("Redirecionando para tela principal do PRESTADOR");
    }

    onShowMessage?.call('Login feito com sucesso!', true);
    onNavigateToMain?.call(dadosUsuario, cpfCnpj, tipoConta);
  }

  void _navegarParaCadastro(User user) {
    onNavigateToCadastro?.call(
      user.email ?? '',
      user.displayName ?? '',
      user.uid,
    );
  }
}