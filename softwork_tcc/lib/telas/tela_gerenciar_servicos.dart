import 'package:flutter/material.dart';
import '../controllers/servicos_controller.dart';

class TelaGerenciarServicos extends StatefulWidget {
  final String nomeUsuario;
  final String cpfCnpj;

  const TelaGerenciarServicos({
    Key? key,
    required this.nomeUsuario,
    required this.cpfCnpj,
  }) : super(key: key);

  @override
  _TelaGerenciarServicosState createState() => _TelaGerenciarServicosState();
}

class _TelaGerenciarServicosState extends State<TelaGerenciarServicos> {

  final ServicosController _servicosController = ServicosController();

  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _categoriaController = TextEditingController();

  List<Map<String, dynamic>> _servicos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarServicos();
  }

  Future<void> _carregarServicos() async {
    try {
      setState(() {
        _isLoading = true;
      });

      List<Map<String, dynamic>> servicos = await _servicosController
          .carregarServicosPorPrestador(widget.cpfCnpj);

      setState(() {
        _servicos = servicos;
        _isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar serviços: $e");
      setState(() {
        _isLoading = false;
      });
      _mostrarErro("Erro ao carregar serviços: ${e.toString()}");
    }
  }

  void _mostrarDialogCadastroServico() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cadastrar Novo Serviço',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome do serviço',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),

                SizedBox(height: 16),

                TextField(
                  controller: _descricaoController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),

                SizedBox(height: 16),

                TextField(
                  controller: _valorController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Valor (R\$)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    prefixText: 'R\$ ',
                  ),
                ),

                SizedBox(height: 16),

                TextField(
                  controller: _categoriaController,
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _limparCampos();
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),

            ElevatedButton(
              onPressed: _cadastrarServico,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Cadastrar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogEdicaoServico(Map<String, dynamic> servico, int index) {

    _nomeController.text = servico['nome'] ?? '';
    _descricaoController.text = servico['descricao'] ?? '';
    _valorController.text = servico['valor']?.toString() ?? '';
    _categoriaController.text = servico['categoria'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Editar Serviço',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome do serviço',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),

                SizedBox(height: 16),

                TextField(
                  controller: _descricaoController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),

                SizedBox(height: 16),

                TextField(
                  controller: _valorController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Valor (R\$)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    prefixText: 'R\$ ',
                  ),
                ),

                SizedBox(height: 16),

                TextField(
                  controller: _categoriaController,
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _limparCampos();
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),

            ElevatedButton(
              onPressed: () => _editarServico(servico['id'], index),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cadastrarServico() async {
    try {
      Map<String, dynamic> novoServico = await _servicosController.cadastrarServico(
        nome: _nomeController.text,
        descricao: _descricaoController.text,
        valor: _valorController.text,
        categoria: _categoriaController.text,
        prestadorCpfCnpj: widget.cpfCnpj,
        prestadorNome: widget.nomeUsuario,
      );

      setState(() {
        _servicos.add(novoServico);
      });

      _limparCampos();
      Navigator.of(context).pop();

      _mostrarSucesso("Serviço cadastrado com sucesso!");

    } catch (e) {
      print("Erro ao cadastrar serviço: $e");
      _mostrarErro(e.toString());
    }
  }

  Future<void> _editarServico(String servicoId, int index) async {
    try {
      await _servicosController.atualizarServico(
        servicoId: servicoId,
        nome: _nomeController.text,
        descricao: _descricaoController.text,
        valor: _valorController.text,
        categoria: _categoriaController.text,
      );

      setState(() {
        _servicos[index]['nome'] = _nomeController.text.trim();
        _servicos[index]['descricao'] = _descricaoController.text.trim();
        _servicos[index]['valor'] = double.parse(_valorController.text.trim().replaceAll(',', '.'));
        _servicos[index]['categoria'] = _categoriaController.text.trim();
      });

      _limparCampos();
      Navigator.of(context).pop();

      _mostrarSucesso("Serviço atualizado com sucesso!");

    } catch (e) {
      print("Erro ao editar serviço: $e");
      _mostrarErro(e.toString());
    }
  }

  Future<void> _excluirServico(String servicoId, int index) async {

    bool? confirmar = await _mostrarConfirmacao(
        "Excluir Serviço",
        "Tem certeza que deseja excluir este serviço?"
    );

    if (confirmar == true) {
      try {
        await _servicosController.excluirServico(servicoId);

        setState(() {
          _servicos.removeAt(index);
        });

        _mostrarSucesso("Serviço excluído com sucesso!");

      } catch (e) {
        print("Erro ao excluir serviço: $e");
        _mostrarErro("Erro ao excluir serviço: ${e.toString()}");
      }
    }
  }

  void _mostrarDescricaoCompleta(String nomeServico, String descricao) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            nomeServico,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              descricao,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarErro(String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Erro!'),
            ],
          ),
          content: Text(mensagem),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarSucesso(String mensagem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Sucesso!'),
            ],
          ),
          content: Text(mensagem),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _mostrarConfirmacao(String titulo, String mensagem) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _limparCampos() {
    _nomeController.clear();
    _descricaoController.clear();
    _valorController.clear();
    _categoriaController.clear();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
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
                        'Meus Serviços',
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

              SizedBox(height: 40),

              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: _mostrarDialogCadastroServico,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      'Cadastrar novo serviço',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              if (!_isLoading) ...[
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Serviços cadastrados: ${_servicos.length}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],

              Expanded(
                child: _isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                )
                    : _servicos.isEmpty
                    ? Center(
                  child: Text(
                    'Nenhum serviço cadastrado',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: _servicos.length,
                  itemBuilder: (context, index) {
                    final servico = _servicos[index];
                    String descricao = servico['descricao'] ?? '';
                    bool descricaoLonga = descricao.length > 80;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      color: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    servico['nome'] ?? '',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),

                                SizedBox(width: 12),

                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red[600],
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      servico['categoria'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Descrição: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  descricaoLonga
                                      ? '${descricao.substring(0, 80)}...'
                                      : descricao,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    height: 1.4,
                                  ),
                                ),
                                if (descricaoLonga) ...[
                                  SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () {
                                      _mostrarDescricaoCompleta(
                                          servico['nome'] ?? 'Serviço',
                                          descricao
                                      );
                                    },
                                    child: Text(
                                      'Ler mais',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.red[800],
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'R\$ ${servico['valor']?.toStringAsFixed(2) ?? '0,00'}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green[600],
                                  ),
                                ),

                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.blue[600], size: 22),
                                      onPressed: () {
                                        _mostrarDialogEdicaoServico(servico, index);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red[600], size: 22),
                                      onPressed: () {
                                        _excluirServico(servico['id'], index);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}