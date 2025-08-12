import 'package:flutter/material.dart';
import '../controllers/cadastro_controller.dart';
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
  final CadastroController _cadastroController = CadastroController();
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _cepController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _idadeController = TextEditingController();

  bool _tipoConta = true;

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.nome;
    _configurarCallbacks();
  }

  void _configurarCallbacks() {
    _cadastroController.setCallbacks(
      loadingCallback: (bool isLoading) {
        setState(() {});
      },
      messageCallback: (String message, bool isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isSuccess ? Colors.green : Colors.red,
          ),
        );
      },
      sucessoCallback: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => TelaLogin()),
              (Route<dynamic> route) => false,
        );
      },
    );
  }

  Future<void> _cadastrar() async {
    if (_formKey.currentState!.validate()) {
      await _cadastroController.cadastrar(
        email: widget.email,
        uid: widget.uid,
        nome: _nomeController.text,
        telefone: _telefoneController.text,
        logradouro: _logradouroController.text,
        cep: _cepController.text,
        cpfCnpj: _cpfCnpjController.text,
        idade: _idadeController.text,
        tipoConta: _tipoConta,
      );
    }
  }

  Future<void> _voltarParaLogin() async {
    await _cadastroController.voltarParaLogin();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => TelaLogin()),
          (Route<dynamic> route) => false,
    );
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
                      onPressed: _voltarParaLogin,
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
                  validator: _cadastroController.validarNome,
                ),

                SizedBox(height: 20),

                _buildLabel('Telefone (somente números)'),
                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(),
                  validator: _cadastroController.validarTelefone,
                ),

                SizedBox(height: 20),

                _buildLabel('Idade'),
                TextFormField(
                  controller: _idadeController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(),
                  validator: _cadastroController.validarIdade,
                ),

                SizedBox(height: 20),

                _buildLabel('Logradouro'),
                TextFormField(
                  controller: _logradouroController,
                  decoration: _buildInputDecoration(),
                  validator: _cadastroController.validarLogradouro,
                ),

                SizedBox(height: 20),

                _buildLabel('CEP'),
                TextFormField(
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(),
                  validator: _cadastroController.validarCEP,
                ),

                SizedBox(height: 20),

                _buildLabel('CPF ou CNPJ (somente números)'),
                TextFormField(
                  controller: _cpfCnpjController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(),
                  validator: _cadastroController.validarCPFCNPJ,
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
                    onPressed: _cadastroController.isLoading ? null : _cadastrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      elevation: 0,
                    ),
                    child: _cadastroController.isLoading
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