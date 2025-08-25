import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _atualizarMascaraCpfCnpj(String texto) {
    String numeroLimpo = texto.replaceAll(RegExp(r'[^\d]'), '');

    TextInputFormatter formatter = CadastroController.getCpfCnpjFormatter(texto);

    final novoValor = formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: numeroLimpo, selection: TextSelection.collapsed(offset: numeroLimpo.length)),
    );

    if (_cpfCnpjController.text != novoValor.text) {
      _cpfCnpjController.value = novoValor;
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.grey[50],
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Para prosseguir com sua conta google, é necessário que preencha o restante de suas informações!',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.red[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'E-mail cadastrado: ${widget.email}',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
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

                _buildLabel('Telefone'),
                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CadastroController.telefoneMaskFormatter],
                  decoration: _buildInputDecoration(),
                  validator: _cadastroController.validarTelefone,
                ),

                SizedBox(height: 20),

                _buildLabel('Idade'),
                TextFormField(
                  controller: _idadeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: CadastroController.idadeFormatters,
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
                  inputFormatters: [CadastroController.cepMaskFormatter],
                  decoration: _buildInputDecoration(),
                  validator: _cadastroController.validarCEP,
                ),

                SizedBox(height: 20),

                _buildLabel('CPF ou CNPJ'),
                TextFormField(
                  controller: _cpfCnpjController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(),
                  onChanged: _atualizarMascaraCpfCnpj,
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
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('Prestador Autônomo'),
                        value: false,
                        groupValue: _tipoConta,
                        onChanged: (value) {
                          setState(() {
                            _tipoConta = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _cadastroController.isLoading ? null : _cadastrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: _cadastroController.isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      'Cadastrar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}