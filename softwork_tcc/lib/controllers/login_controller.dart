import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import '../controllers/notificacao_controller.dart';

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
// Verifica se há usuário logado e redireciona automaticamente
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
// Realiza login com email e senha no Firebase
  Future<void> loginComEmailSenha(String email, String senha) async {
    _setLoading(true);

    try {
      print("Iniciando login com email/senha...");

      UserCredential? userCredential;
      User? userFinal;

      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: senha,
        );

        userFinal = userCredential.user;

      } catch (e) {
        print("Erro durante signInWithEmailAndPassword: $e");

        if (e.toString().contains('PigeonUserDetails') ||
            e.toString().contains('List<Object?>') ||
            e.toString().contains('type cast')) {

          print("Erro conhecido do Firebase Auth, verificando currentUser...");

          await Future.delayed(Duration(milliseconds: 500));

          User? currentUser = _auth.currentUser;
          if (currentUser != null && currentUser.email == email.trim()) {
            print("Login realizado apesar do erro! Email: ${currentUser.email}");
            userFinal = currentUser;
          } else {
            throw e;
          }
        } else {
          throw e;
        }
      }

      if (userFinal != null) {
        print("Login realizado com sucesso: ${userFinal.email}");
        print("UID do usuário: ${userFinal.uid}");
        await _verificarCadastroCompleto(userFinal);
      } else {
        throw Exception("Usuário nulo após login");
      }

    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code}");

      String mensagemErro = 'Erro login, verifique o email ou senha digitado';

      switch(e.code) {
        case 'user-not-found':
          mensagemErro = 'Erro login, verifique o email ou senha digitado';
          break;
        case 'wrong-password':
          mensagemErro = 'Erro login, verifique o email ou senha digitado';
          break;
        case 'invalid-email':
          mensagemErro = 'Email inválido';
          break;
        case 'user-disabled':
          mensagemErro = 'Usuário desabilitado';
          break;
        case 'too-many-requests':
          mensagemErro = 'Muitas tentativas. Tente novamente mais tarde';
          break;
        case 'invalid-credential':
          mensagemErro = 'Erro login, verifique o email ou senha digitado';
          break;
      }

      onShowMessage?.call(mensagemErro, false);

    } catch (e) {
      print("Erro geral ao fazer login: $e");
      print("Tipo do erro: ${e.runtimeType}");

      String mensagemErro = 'Erro ao fazer login. Tente novamente.';

      if (e.toString().contains('network')) {
        mensagemErro = 'Erro de conexão. Verifique sua internet.';
      }

      onShowMessage?.call(mensagemErro, false);
    } finally {
      _setLoading(false);
    }
  }
// Prepara criação de conta com email e senha
  Future<void> criarContaComEmailSenha(String email, String senha) async {
    if (email.trim().isEmpty || senha.isEmpty) {
      onShowMessage?.call('Email e senha são obrigatórios', false);
      return;
    }

    if (senha.length < 6) {
      onShowMessage?.call('Senha deve ter pelo menos 6 caracteres', false);
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email.trim())) {
      onShowMessage?.call('Email inválido', false);
      return;
    }

    onNavigateToCadastro?.call(
        email.trim(),
        '',
        ''
    );
  }
// Realiza login usando conta Google
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
// Verifica se cadastro do usuário está completo no banco
  Future<void> _verificarCadastroCompleto(User user) async {
    try {
      print("DEBUG VERIFICAR CADASTRO");
      print("Email do usuário: ${user.email}");
      print("UID do usuário: ${user.uid}");

      final DatabaseReference ref = FirebaseDatabase.instance.ref();

      print("Buscando no banco de dados...");
      final snapshot = await ref.child('usuarios').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> usuarios = snapshot.value as Map<dynamic, dynamic>;

        bool cadastroCompleto = false;
        String? cpfCnpjUsuario;
        Map<dynamic, dynamic>? dadosUsuario;

        for (var entry in usuarios.entries) {
          var dados = entry.value as Map<dynamic, dynamic>;

          if (dados['email'] == user.email) {
            print("Email encontrado! Verificando completude...");

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
          print("Redirecionando para tela principal...");

          // NOVO: Salvar token FCM do usuário
          await NotificacaoController.salvarTokenUsuario(cpfCnpjUsuario);

          bool isPrestador = dadosUsuario['tipoConta'] == false;

          onNavigateToMain?.call(dadosUsuario, cpfCnpjUsuario, isPrestador);
        } else {
          print("Cadastro incompleto ou não encontrado. Redirecionando para cadastro...");
          onNavigateToCadastro?.call(user.email!, user.uid, user.displayName ?? '');
        }
      } else {
        print("Nenhum usuário encontrado no banco. Redirecionando para cadastro...");
        onNavigateToCadastro?.call(user.email!, user.uid, user.displayName ?? '');
      }

    } catch (e) {
      print("ERRO ao verificar cadastro completo: $e");
      onShowMessage?.call('Erro ao verificar dados do usuário', false);
    }
  }
}