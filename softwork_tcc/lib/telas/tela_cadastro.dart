import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'tela_login.dart';

class TelaCadastro extends StatefulWidget {
  final String email;
  final String nome;
  final String uid;

  const TelaCadastro({
    Key? key,
    required this.email,
    required this.nome,
    required this.uid,
  }) : super(key: key);

  @override
  _TelaCadastroState createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _cepController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _idadeController = TextEditingController();

  bool _tipoConta = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.nome;
  }

  Future<void> _cadastrar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String cpfCnpjLimpo = _cpfCnpjController.text.replaceAll(RegExp(r'[^\d]'), '');
        String telefoneLimpo = _telefoneController.text.replaceAll(RegExp(r'[^\d]'), '');

        final DatabaseReference ref = FirebaseDatabase.instance.ref();

        final snapshot = await ref.child('usuarios/$cpfCnpjLimpo').get();

        if (snapshot.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Já existe uma conta cadastrada com este CPF/CNPJ'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        Map<String, dynamic> dadosUsuario = {
          'email': widget.email,
          'nome': _nomeController.text.trim(),
          'telefone': telefoneLimpo,
          'logradouro': _logradouroController.text.trim(),
          'cep': _cepController.text.trim(),
          'cpfCnpj': cpfCnpjLimpo,
          'tipoConta': _tipoConta,
          'idade': int.parse(_idadeController.text.trim()),
          'uid': widget.uid,
        };

        await ref.child('usuarios/$cpfCnpjLimpo').set(dadosUsuario);

        print("Cadastro realizado com sucesso!");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        await FirebaseAuth.instance.signOut();
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => TelaLogin()),
              (Route<dynamic> route) => false,
        );

      } catch (e) {
        print("Erro ao cadastrar: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao realizar cadastro'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validarTelefone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o telefone';
    }

    String telefoneLimpo = value.replaceAll(RegExp(r'[^\d]'), '');

    if (telefoneLimpo.length < 10 || telefoneLimpo.length > 11) {
      return 'Telefone deve ter 10 ou 11 dígitos';
    }

    return null;
  }

  String? _validarIdade(String? value) {
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

  String? _validarCPFCNPJ(String? value) {
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

  String? _validarCEP(String? value) {
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

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _logradouroController.dispose();
    _cepController.dispose();
    _cpfCnpjController.dispose();
    _idadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, size: 28),
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signOut();
                          final GoogleSignIn googleSignIn = GoogleSignIn();
                          await googleSignIn.signOut();

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => TelaLogin()),
                                (Route<dynamic> route) => false,
                          );
                        } catch (e) {
                          print("Erro ao fazer logout: $e");
                        }
                      },
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Cadastro',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Para prosseguir com sua conta google, é necessário que preencha o restante de suas informações!',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                _buildLabel('Nome completo'),
                TextFormField(
                  controller: _nomeController,
                  decoration: _buildInputDecoration(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome completo';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                _buildLabel('Telefone (somente números)'),
                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(),
                  validator: _validarTelefone,
                ),

                SizedBox(height: 20),

                _buildLabel('Idade'),
                TextFormField(
                  controller: _idadeController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(),
                  validator: _validarIdade,
                ),

                SizedBox(height: 20),

                _buildLabel('Logradouro'),
                TextFormField(
                  controller: _logradouroController,
                  decoration: _buildInputDecoration(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o logradouro';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                _buildLabel('CEP'),
                TextFormField(
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(),
                  validator: _validarCEP,
                ),

                SizedBox(height: 20),

                _buildLabel('CPF ou CNPJ (somente números)'),
                TextFormField(
                  controller: _cpfCnpjController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(),
                  validator: _validarCPFCNPJ,
                ),

                SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('Cliente'),
                        value: true,
                        groupValue: _tipoConta,
                        onChanged: (value) {
                          setState(() {
                            _tipoConta = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('Prestador\nAutônomo'),
                        value: false,
                        groupValue: _tipoConta,
                        onChanged: (value) {
                          setState(() {
                            _tipoConta = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _cadastrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : Text(
                      'Cadastrar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!, style: BorderStyle.solid, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!, style: BorderStyle.solid, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}