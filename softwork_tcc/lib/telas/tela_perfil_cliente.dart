import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../controllers/perfil_cliente_controller.dart';

class TelaPerfilCliente extends StatefulWidget {
  final String clienteCpfCnpj;
  final bool isMeuPerfil;

  const TelaPerfilCliente({
    Key? key,
    required this.clienteCpfCnpj,
    this.isMeuPerfil = false,
  }) : super(key: key);

  @override
  _TelaPerfilClienteState createState() => _TelaPerfilClienteState();
}

class _TelaPerfilClienteState extends State<TelaPerfilCliente> {
  final PerfilClienteController _controller = PerfilClienteController();
  bool _isLoading = true;

  final telefoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _configurarCallbacks();
    _carregarDados();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _configurarCallbacks() {
    _controller.setCallbacks(
      loadingCallback: (bool isLoading) {
        setState(() {
          _isLoading = isLoading;
        });
      },
      dataCallback: () {
        setState(() {});
      },
      errorCallback: (String erro) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(erro),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  Future<void> _carregarDados() async {
    await _controller.carregarDadosCliente(widget.clienteCpfCnpj);
  }

  void _mostrarDialogEditarNome() {
    final TextEditingController nomeController = TextEditingController();
    nomeController.text = _controller.getNome();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Editar Nome',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nomeController,
            maxLength: 100,
            decoration: InputDecoration(
              hintText: 'Digite seu nome completo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red[600]!, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                String novoNome = nomeController.text.trim();

                if (novoNome.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Nome não pode estar vazio'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await _controller.salvarNome(widget.clienteCpfCnpj, novoNome);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Nome atualizado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao salvar nome'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                'Salvar',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogEditarTelefone() {
    final TextEditingController telefoneController = TextEditingController();
    String telefoneAtual = _controller.getTelefone();
    telefoneController.text = telefoneAtual;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Editar Telefone',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: telefoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [telefoneMaskFormatter],
            decoration: InputDecoration(
              hintText: '(00) 00000-0000',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red[600]!, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                String novoTelefone = telefoneController.text.trim();

                if (novoTelefone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Telefone não pode estar vazio'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await _controller.salvarTelefone(widget.clienteCpfCnpj, novoTelefone);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Telefone atualizado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                'Salvar',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogEditarBiografia() {
    final TextEditingController biografiaController = TextEditingController();
    biografiaController.text = _controller.temBiografia() ? _controller.getBiografia() : '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Editar Biografia',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: TextField(
              controller: biografiaController,
              maxLines: 5,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'Conte um pouco sobre você...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.red[600]!, width: 2),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                String novaBiografia = biografiaController.text.trim();

                try {
                  await _controller.salvarBiografia(widget.clienteCpfCnpj, novaBiografia);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Biografia atualizada com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao salvar biografia'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                'Salvar',
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: Colors.red[600],
          ),
        )
            : SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Perfil do Cliente',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40),
                ],
              ),

              SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _controller.getNome(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (widget.isMeuPerfil)
                          GestureDetector(
                            onTap: _mostrarDialogEditarNome,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                color: Colors.blue[600],
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      _controller.getIdade(),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 20),
                    Divider(color: Colors.grey[200]),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Icon(Icons.email_outlined, color: Colors.grey[600], size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _controller.getEmail(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, color: Colors.grey[600], size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _controller.getTelefone(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                        if (widget.isMeuPerfil)
                          GestureDetector(
                            onTap: _mostrarDialogEditarTelefone,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.edit,
                                color: Colors.blue[600],
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _controller.getLogradouro(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.pin_drop_outlined, color: Colors.grey[600], size: 18),
                        SizedBox(width: 10),
                        Text(
                          _controller.getCep(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sobre mim',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (widget.isMeuPerfil)
                    GestureDetector(
                      onTap: _mostrarDialogEditarBiografia,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Editar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _controller.temBiografia() ? Colors.white : Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _controller.getBiografia(),
                  style: TextStyle(
                    fontSize: 14,
                    color: _controller.temBiografia() ? Colors.grey[700] : Colors.grey[500],
                    height: 1.5,
                    fontStyle: _controller.temBiografia() ? FontStyle.normal : FontStyle.italic,
                  ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}