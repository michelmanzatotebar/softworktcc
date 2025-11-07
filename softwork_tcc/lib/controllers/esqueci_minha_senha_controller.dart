import 'package:firebase_auth/firebase_auth.dart';

class EsqueciMinhaSenhaController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Function(bool)? onLoadingChanged;
  Function(String, bool)? onShowMessage;
  Function()? onNavigateBack;

  void setCallbacks({
    Function(bool)? loadingCallback,
    Function(String, bool)? messageCallback,
    Function()? backCallback,
  }) {
    onLoadingChanged = loadingCallback;
    onShowMessage = messageCallback;
    onNavigateBack = backCallback;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    onLoadingChanged?.call(_isLoading);
  }
// Envia email para redefinição de senha via Firebase Auth
  Future<void> enviarEmailRedefinirSenha(String email) async {
    if (email.trim().isEmpty) {
      onShowMessage?.call('Email é obrigatório', false);
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email.trim())) {
      onShowMessage?.call('Email inválido', false);
      return;
    }

    _setLoading(true);

    try {
      print("=== DEBUG RESET SENHA ===");
      print("Email para reset: ${email.trim()}");

      await _auth.sendPasswordResetEmail(email: email.trim());

      print("Email reset enviado com sucesso!");
      onShowMessage?.call('Email de redefinição enviado! Verifique sua caixa de entrada e spam.', true);

      await Future.delayed(Duration(seconds: 2));
      onNavigateBack?.call();

    } on FirebaseAuthException catch (e) {
      print("Erro FirebaseAuth: ${e.code}");
      print("Mensagem: ${e.message}");

      String mensagemErro = 'Erro ao enviar email de redefinição';

      switch(e.code) {
        case 'user-not-found':
          mensagemErro = 'Email não encontrado no sistema';
          break;
        case 'invalid-email':
          mensagemErro = 'Email inválido';
          break;
        case 'too-many-requests':
          mensagemErro = 'Muitas tentativas. Tente novamente mais tarde';
          break;
      }

      onShowMessage?.call(mensagemErro, false);
    } catch (e) {
      print("Erro geral: $e");
      onShowMessage?.call('Erro ao enviar email. Tente novamente.', false);
    } finally {
      _setLoading(false);
    }
  }
}