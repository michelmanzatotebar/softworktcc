import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _cepController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _idadeController = TextEditingController();

  bool _tipoConta = true;
  bool _obscurePassword = true;
  bool _isGoogleLogin = false;

  @override
  void initState() {
    super.initState();
    _isGoogleLogin = widget.uid.isNotEmpty;
    _emailController.text = widget.email;
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

  InputDecoration _buildInputDecoration({bool readOnly = false}) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: readOnly ? Colors.grey[200]! : Colors.grey[300]!, width: 1),
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
      fillColor: readOnly ? Colors.grey[100] : Colors.grey[50],
    );
  }

  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }

    return null;
  }

  String? _validarSenha(String? value) {
    if (_isGoogleLogin) return null; // Não valida senha para login Google

    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }

    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }

    return null;
  }

  String? _validarCpfCnpjTeste(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o CPF ou CNPJ';
    }

    String numeroLimpo = value.replaceAll(RegExp(r'[^\d]'), '');

    if (numeroLimpo.length != 11 && numeroLimpo.length != 14) {
      return 'CPF deve ter 11 dígitos ou CNPJ deve ter 14 dígitos';
    }

    // TEMPORÁRIO: Aceita CPFs/CNPJs de teste (sequências repetidas de 1 a 9)
    List<String> cpfsValidos = [
      '11111111111', '22222222222', '33333333333', '44444444444',
      '55555555555', '66666666666', '77777777777', '88888888888', '99999999999'
    ];

    List<String> cnpjsValidos = [
      '11111111111111', '22222222222222', '33333333333333', '44444444444444',
      '55555555555555', '66666666666666', '77777777777777', '88888888888888', '99999999999999'
    ];

    if (numeroLimpo.length == 11 && cpfsValidos.contains(numeroLimpo)) {
      return null; // CPF de teste válido
    }

    if (numeroLimpo.length == 14 && cnpjsValidos.contains(numeroLimpo)) {
      return null; // CNPJ de teste válido
    }

    // Se não é um teste, usar validação real
    return _cadastroController.validarCPFCNPJ(value);
  }

  Future<void> _cadastrar() async {
    if (_formKey.currentState!.validate()) {
      String emailFinal = _emailController.text.trim();
      String senhaFinal = _senhaController.text;
      String uidFinal = widget.uid;

      // Se é cadastro por email/senha (UID vazio), criar conta Firebase primeiro
      if (!_isGoogleLogin && uidFinal.isEmpty) {
        try {
          setState(() {});

          print("=== DEBUG CRIAR CONTA ===");
          print("Email: $emailFinal");
          print("Senha length: ${senhaFinal.length}");
          print("Criando conta Firebase Auth com email/senha...");

          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailFinal,
            password: senhaFinal,
          );

          // Sempre pegar UID do currentUser para evitar bug do PigeonUserDetails
          User? currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            uidFinal = currentUser.uid;
            print("✅ Conta criada! UID: $uidFinal");
          } else {
            throw Exception("Erro ao obter UID da conta criada");
          }

        } catch (e) {
          print("❌ ERRO DETALHADO: $e");
          print("❌ TIPO ERRO: ${e.runtimeType}");

          // Se for o erro do PigeonUserDetails mas a conta foi criada, continuar
          if (e.toString().contains('PigeonUserDetails') || e.toString().contains('List<Object?>')) {
            print("🔧 Erro conhecido do Firebase Auth, verificando currentUser...");

            User? currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              uidFinal = currentUser.uid;
              print("✅ Conta criada apesar do erro! UID: $uidFinal");
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro interno do Firebase. Tente novamente.'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                ),
              );
              return;
            }
          } else {
            // Outros erros reais
            String mensagemErro = 'Erro ao criar conta';

            if (e.toString().contains('email-already-in-use')) {
              mensagemErro = 'Este email já está em uso';
            } else if (e.toString().contains('weak-password')) {
              mensagemErro = 'Senha muito fraca (mínimo 6 caracteres)';
            } else if (e.toString().contains('invalid-email')) {
              mensagemErro = 'Email inválido';
            } else if (e.toString().contains('operation-not-allowed')) {
              mensagemErro = 'Login email/senha não habilitado no Firebase';
            } else if (e.toString().contains('network')) {
              mensagemErro = 'Erro de conexão com Firebase';
            } else {
              mensagemErro = 'Erro ao criar conta: ${e.toString()}';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(mensagemErro),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
            return; // Para aqui se deu erro real
          }
        }
      }

      // Agora cadastra no banco com UID válido
      await _cadastroController.cadastrar(
        email: emailFinal,
        uid: uidFinal,
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
    _emailController.dispose();
    _senhaController.dispose();
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

                // Card informativo para Google login
                if (_isGoogleLogin) ...[
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
                ],

                // Card informativo para email/senha
                if (!_isGoogleLogin) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Complete suas informações para criar sua conta no SoftWork',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                ],

                // Campo Email
                _buildLabel('Email'),
                TextFormField(
                  controller: _emailController,
                  readOnly: _isGoogleLogin,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validarEmail,
                  decoration: _buildInputDecoration(readOnly: _isGoogleLogin),
                ),

                SizedBox(height: 20),

                // Campo Senha (só aparece para email/senha)
                if (!_isGoogleLogin) ...[
                  _buildLabel('Senha'),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: _obscurePassword,
                    validator: _validarSenha,
                    decoration: _buildInputDecoration().copyWith(
                      hintText: 'Digite sua senha',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],

                // Campo Nome
                _buildLabel('Nome completo'),
                TextFormField(
                  controller: _nomeController,
                  maxLength: 100,
                  decoration: _buildInputDecoration(),
                  validator: _cadastroController.validarNome,
                ),

                SizedBox(height: 20),

                // Campo Telefone
                _buildLabel('Telefone'),
                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [CadastroController.telefoneMaskFormatter],
                  decoration: _buildInputDecoration(),
                  validator: _cadastroController.validarTelefone,
                ),

                SizedBox(height: 20),

                // Campo Logradouro
                _buildLabel('Endereço'),
                TextFormField(
                  controller: _logradouroController,
                  decoration: _buildInputDecoration(),
                  validator: _cadastroController.validarLogradouro,
                ),

                SizedBox(height: 20),

                // Campo CEP
                _buildLabel('CEP'),
                TextFormField(
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CadastroController.cepMaskFormatter],
                  decoration: _buildInputDecoration(),
                  validator: _cadastroController.validarCEP,
                ),

                SizedBox(height: 20),

                // Campo CPF/CNPJ
                _buildLabel('CPF/CNPJ'),
                TextFormField(
                  controller: _cpfCnpjController,
                  keyboardType: TextInputType.number,
                  onChanged: _atualizarMascaraCpfCnpj,
                  decoration: _buildInputDecoration(),
                  validator: _validarCpfCnpjTeste, // TEMPORÁRIO para testes
                ),

                SizedBox(height: 20),

                // Campo Idade
                _buildLabel('Idade'),
                TextFormField(
                  controller: _idadeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: CadastroController.idadeFormatters,
                  decoration: _buildInputDecoration(),
                  validator: _cadastroController.validarIdade,
                ),

                SizedBox(height: 30),

                // Seleção Tipo de Conta
                _buildLabel('Tipo de conta'),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<bool>(
                        title: Text('Cliente'),
                        value: true,
                        groupValue: _tipoConta,
                        onChanged: (bool? value) {
                          setState(() {
                            _tipoConta = value!;
                          });
                        },
                      ),
                      Divider(height: 1, color: Colors.grey[300]),
                      RadioListTile<bool>(
                        title: Text('Prestador'),
                        value: false,
                        groupValue: _tipoConta,
                        onChanged: (bool? value) {
                          setState(() {
                            _tipoConta = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),

                // Botão Cadastrar
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
                    onPressed: _cadastroController.isLoading ? null : _cadastrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _cadastroController.isLoading
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      'Cadastrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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