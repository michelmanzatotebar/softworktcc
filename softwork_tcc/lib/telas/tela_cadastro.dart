import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _logradouroController = TextEditingController();
  final _cepController = TextEditingController();
  final _cpfCnpjController = TextEditingController();

  bool _tipoConta = true; // true = Cliente, false = Prestador Autônomo
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Preencher o nome se vier do Google
    _nomeController.text = widget.nome;
  }

  Future<void> _cadastrar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String cpfCnpjLimpo = _cpfCnpjController.text.replaceAll(RegExp(r'[^\d]'), '');

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
          'logradouro': _logradouroController.text.trim(),
          'cep': _cepController.text.trim(),
          'cpfCnpj': cpfCnpjLimpo,
          'tipoConta': _tipoConta,
          'uid': widget.uid,
          'dataCadastro': DateTime.now().toIso8601String(),
        };

        await ref.child('usuarios/$cpfCnpjLimpo').set(dadosUsuario);

        print("Cadastro realizado com sucesso!");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar para a tela principal do app


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

  String? _validarCPFCNPJ(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o CPF ou CNPJ';
    }

    String numeroLimpo = value.replaceAll(RegExp(r'[^\d]'), '');

    if (numeroLimpo.length != 11 && numeroLimpo.length != 14) {
      return 'CPF deve ter 11 dígitos ou CNPJ deve ter 14 dígitos';
    }

    return null;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _logradouroController.dispose();
    _cepController.dispose();
    _cpfCnpjController.dispose();
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


                _buildLabel('Email'),
                TextFormField(
                  initialValue: widget.email,
                  enabled: false,
                  decoration: _buildInputDecoration(),
                  style: TextStyle(color: Colors.grey[600]),
                ),

                SizedBox(height: 20),

                _buildLabel('Senha'),
                TextFormField(
                  initialValue: '••••••••',
                  enabled: false,
                  obscureText: true,
                  decoration: _buildInputDecoration(),
                  style: TextStyle(color: Colors.grey[600]),
                ),

                SizedBox(height: 20),

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

                // Campo CEP
                _buildLabel('CEP'),
                TextFormField(
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o CEP';
                    }
                    String cepLimpo = value.replaceAll(RegExp(r'[^\d]'), '');
                    if (cepLimpo.length != 8) {
                      return 'CEP deve ter 8 dígitos';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 20),

                _buildLabel('CPF ou CNPJ'),
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