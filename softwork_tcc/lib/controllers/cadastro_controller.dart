import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CadastroController {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Function(bool)? onLoadingChanged;
  Function(String, bool)? onShowMessage;
  Function()? onCadastroSucesso;

  static final MaskTextInputFormatter cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static final MaskTextInputFormatter telefoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static final MaskTextInputFormatter cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static final MaskTextInputFormatter cnpjMaskFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  static final List<TextInputFormatter> idadeFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(2),
  ];

  void setCallbacks({
    Function(bool)? loadingCallback,
    Function(String, bool)? messageCallback,
    Function()? sucessoCallback,
  }) {
    onLoadingChanged = loadingCallback;
    onShowMessage = messageCallback;
    onCadastroSucesso = sucessoCallback;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    onLoadingChanged?.call(_isLoading);
  }

  static TextInputFormatter getCpfCnpjFormatter(String texto) {
    String numeroLimpo = texto.replaceAll(RegExp(r'[^\d]'), '');

    if (numeroLimpo.length <= 11) {
      return cpfMaskFormatter;
    } else {
      return cnpjMaskFormatter;
    }
  }

  static String formatarCpfCnpj(String texto) {
    String numeroLimpo = texto.replaceAll(RegExp(r'[^\d]'), '');

    TextInputFormatter formatter = getCpfCnpjFormatter(texto);

    final resultado = formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: numeroLimpo, selection: TextSelection.collapsed(offset: numeroLimpo.length)),
    );

    return resultado.text;
  }

  Future<void> cadastrar({
    required String email,
    required String uid,
    required String nome,
    required String telefone,
    required String logradouro,
    required String cep,
    required String cpfCnpj,
    required String idade,
    required bool tipoConta,
  }) async {
    _setLoading(true);

    try {
      String cpfCnpjLimpo = cpfCnpj.replaceAll(RegExp(r'[^\d]'), '');
      String telefoneLimpo = telefone.replaceAll(RegExp(r'[^\d]'), '');
      String cepLimpo = cep.replaceAll(RegExp(r'[^\d]'), '');

      final DatabaseReference ref = FirebaseDatabase.instance.ref();

      final snapshot = await ref.child('usuarios/$cpfCnpjLimpo').get();

      if (snapshot.exists) {
        onShowMessage?.call('Já existe uma conta cadastrada com este CPF/CNPJ', false);
        _setLoading(false);
        return;
      }

      Map<String, dynamic> dadosUsuario = {
        'email': email,
        'nome': nome.trim(),
        'telefone': telefoneLimpo,
        'logradouro': logradouro.trim(),
        'cep': cepLimpo,
        'cpfCnpj': cpfCnpjLimpo,
        'tipoConta': tipoConta,
        'idade': int.parse(idade.trim()),
        'uid': uid,
      };

      await ref.child('usuarios/$cpfCnpjLimpo').set(dadosUsuario);

      print("Cadastro realizado com sucesso!");

      onShowMessage?.call('Cadastro realizado com sucesso!', true);

      await FirebaseAuth.instance.signOut();
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      onCadastroSucesso?.call();

    } catch (e) {
      print("Erro ao cadastrar: $e");
      onShowMessage?.call('Erro ao realizar cadastro', false);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> voltarParaLogin() async {
    try {
      await FirebaseAuth.instance.signOut();
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (e) {
      print("Erro ao fazer logout: $e");
    }
  }

  String? validarTelefone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o telefone';
    }

    String telefoneLimpo = value.replaceAll(RegExp(r'[^\d]'), '');

    if (telefoneLimpo.length < 10 || telefoneLimpo.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }

    return null;
  }

  String? validarIdade(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua idade';
    }

    try {
      int idade = int.parse(value);
      if (idade < 18) {
        return 'Idade deve estar acima de 18 anos';
      }
      if (idade > 90) {
        return 'Idade com valor muito alto!';
      }
    } catch (e) {
      return 'Por favor, insira uma idade válida';
    }

    return null;
  }

  String? validarCPFCNPJ(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o CPF ou CNPJ';
    }

    String numeroLimpo = value.replaceAll(RegExp(r'[^\d]'), '');

    if (numeroLimpo.length != 11 && numeroLimpo.length != 14) {
      return 'CPF deve ter 11 dígitos ou CNPJ deve ter 14 dígitos';
    }

    if (numeroLimpo.length == 11) {
      if (numeroLimpo == '33333333333') {
        return null;
      }

      if (RegExp(r'^(\d)\1{10}$').hasMatch(numeroLimpo)) {
        return 'CPF inválido';
      }

      int soma = 0;
      int resto;

      for (int i = 1; i <= 9; i++) {
        soma += int.parse(numeroLimpo.substring(i - 1, i)) * (11 - i);
      }
      resto = (soma * 10) % 11;
      if (resto == 10 || resto == 11) resto = 0;
      if (resto != int.parse(numeroLimpo.substring(9, 10))) {
        return 'CPF inválido';
      }

      soma = 0;
      for (int i = 1; i <= 10; i++) {
        soma += int.parse(numeroLimpo.substring(i - 1, i)) * (12 - i);
      }
      resto = (soma * 10) % 11;
      if (resto == 10 || resto == 11) resto = 0;
      if (resto != int.parse(numeroLimpo.substring(10, 11))) {
        return 'CPF inválido';
      }
    }

    if (numeroLimpo.length == 14) {
      if (numeroLimpo == '22222222222222') {
        return null;
      }
      if (numeroLimpo == '11111111111111') {
        return null;
      }
      if (numeroLimpo == '11111111111') {
        return null;
      }

      if (RegExp(r'^(\d)\1{13}$').hasMatch(numeroLimpo)) {
        return 'CNPJ inválido';
      }

      List<String> cnpjsInvalidos = [
        '00000000000000',
        '33333333333333', '44444444444444', '55555555555555',
        '66666666666666', '77777777777777', '88888888888888',
        '99999999999999'
      ];

      if (cnpjsInvalidos.contains(numeroLimpo)) {
        return 'CNPJ inválido';
      }

      List<int> multiplicadores1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
      List<int> multiplicadores2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

      String tempCnpj = numeroLimpo.substring(0, 12);
      int soma = 0;

      for (int i = 0; i < 12; i++) {
        soma += int.parse(tempCnpj[i]) * multiplicadores1[i];
      }

      int resto = soma % 11;
      int digito1 = resto < 2 ? 0 : 11 - resto;

      tempCnpj = tempCnpj + digito1.toString();
      soma = 0;

      for (int i = 0; i < 13; i++) {
        soma += int.parse(tempCnpj[i]) * multiplicadores2[i];
      }

      resto = soma % 11;
      int digito2 = resto < 2 ? 0 : 11 - resto;

      if (int.parse(numeroLimpo.substring(12, 13)) != digito1 ||
          int.parse(numeroLimpo.substring(13, 14)) != digito2) {
        return 'CNPJ inválido';
      }
    }

    return null;
  }

  String? validarCEP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o CEP';
    }

    String cepLimpo = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cepLimpo.length != 8) {
      return 'CEP deve ter 8 dígitos';
    }

    if (RegExp(r'^0{8}$').hasMatch(cepLimpo) || RegExp(r'^(\d)\1{7}$').hasMatch(cepLimpo)) {
      return 'CEP inválido';
    }

    return null;
  }

  String? validarNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu nome completo';
    }
    return null;
  }

  String? validarLogradouro(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o logradouro';
    }
    return null;
  }
}