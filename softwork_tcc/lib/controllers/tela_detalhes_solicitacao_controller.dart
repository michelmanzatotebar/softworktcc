import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'solicitacao_controller.dart';

class TelaDetalhesSolicitacaoController {
  final SolicitacaoController _solicitacaoController = SolicitacaoController();
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  final TextEditingController tituloEditController = TextEditingController();
  final TextEditingController descricaoEditController = TextEditingController();

  bool editandoTitulo = false;
  bool editandoDescricao = false;
  bool isLoading = false;

  Map<String, dynamic>? dadosSolicitacao;
  Map<String, dynamic>? dadosPrestadorCompletos;

  VoidCallback? onUpdateUI;
  Function(String, bool)? onShowMessage;
  VoidCallback? onNavigateBack;

  Future<void> inicializarDados(Map<String, dynamic> dados, {
    VoidCallback? updateUI,
    Function(String, bool)? messageCallback,
    VoidCallback? navigateBack,
    String? clienteNome,
    String? clienteCpfCnpj,
  }) async {
    dadosSolicitacao = _processarDadosFirebase(dados);
    onUpdateUI = updateUI;
    onShowMessage = messageCallback;
    onNavigateBack = navigateBack;

    this.clienteNome = clienteNome;
    this.clienteCpfCnpj = clienteCpfCnpj;

    tituloEditController.text = titulo ?? '';
    descricaoEditController.text = descricao ?? '';

    await _buscarDadosPrestadorCompletos();
  }

  Map<String, dynamic> _processarDadosFirebase(dynamic dados) {
    if (dados is Map) {
      Map<String, dynamic> resultado = {};
      dados.forEach((key, value) {
        if (value is Map) {
          resultado[key.toString()] = _processarDadosFirebase(value);
        } else {
          resultado[key.toString()] = value;
        }
      });
      return resultado;
    }
    return dados ?? {};
  }

  Future<void> _buscarDadosPrestadorCompletos() async {
    try {
      isLoading = true;
      onUpdateUI?.call();

      final prestadorData = dadosSolicitacao?['prestador'];
      if (prestadorData == null) {
        print("Dados do prestador não encontrados na solicitação");
        return;
      }

      final cpfCnpjPrestador = prestadorData['cpfCnpj']?.toString();
      if (cpfCnpjPrestador == null || cpfCnpjPrestador.isEmpty) {
        print("CPF/CNPJ do prestador não encontrado");
        return;
      }

      print("Buscando dados do prestador: $cpfCnpjPrestador");

      final snapshot = await _ref.child('usuarios/$cpfCnpjPrestador').get();

      if (snapshot.exists && snapshot.value != null) {
        dadosPrestadorCompletos = _processarDadosFirebase(snapshot.value);
        print("Dados do prestador carregados com sucesso");
      } else {
        print("Prestador não encontrado no banco de dados");
        dadosPrestadorCompletos = null;
      }
    } catch (e) {
      print("Erro ao buscar dados do prestador: $e");
      dadosPrestadorCompletos = null;
    } finally {
      isLoading = false;
      onUpdateUI?.call();
    }
  }

  String? clienteNome;
  String? clienteCpfCnpj;

  String? get titulo => dadosSolicitacao?['titulo']?.toString();
  String? get descricao => dadosSolicitacao?['descricao']?.toString();

  Map<String, dynamic>? get servico {
    final servicoData = dadosSolicitacao?['servico'];
    if (servicoData is Map) {
      return _processarDadosFirebase(servicoData);
    }
    return null;
  }

  Map<String, dynamic>? get cliente {
    final clienteData = dadosSolicitacao?['cliente'];
    if (clienteData is Map) {
      return _processarDadosFirebase(clienteData);
    }
    return null;
  }

  Map<String, dynamic>? get prestador {
    final prestadorData = dadosSolicitacao?['prestador'];
    if (prestadorData is Map) {
      return _processarDadosFirebase(prestadorData);
    }
    return null;
  }

  String? get dataSolicitacao => dadosSolicitacao?['dataSolicitacao']?.toString();
  String? get statusSolicitacao => dadosSolicitacao?['statusSolicitacao']?.toString();

  // Corrigido: pega a categoria do serviço
  String? get categoria => servico?['categoria']?.toString();

  String getPrestadorNome() {
    return dadosPrestadorCompletos?['nome']?.toString() ??
        prestador?['nome']?.toString() ?? 'N/A';
  }

  String getPrestadorIdade() {
    return dadosPrestadorCompletos?['idade']?.toString() ?? 'N/A';
  }

  String getPrestadorEmail() {
    return dadosPrestadorCompletos?['email']?.toString() ?? 'N/A';
  }

  String getPrestadorTelefone() {
    String telefone = dadosPrestadorCompletos?['telefone']?.toString() ?? 'N/A';
    if (telefone != 'N/A' && telefone.length >= 10) {
      String numLimpo = telefone.replaceAll(RegExp(r'[^\d]'), '');
      if (numLimpo.length == 11) {
        return '(${numLimpo.substring(0, 2)}) ${numLimpo.substring(2, 7)}-${numLimpo.substring(7)}';
      } else if (numLimpo.length == 10) {
        return '(${numLimpo.substring(0, 2)}) ${numLimpo.substring(2, 6)}-${numLimpo.substring(6)}';
      }
    }
    return telefone;
  }

  String getPrestadorLogradouro() {
    return dadosPrestadorCompletos?['logradouro']?.toString() ?? 'N/A';
  }

  String getPrestadorCep() {
    String cep = dadosPrestadorCompletos?['cep']?.toString() ?? 'N/A';
    if (cep != 'N/A' && cep.length >= 8) {
      String cepLimpo = cep.replaceAll(RegExp(r'[^\d]'), '');
      if (cepLimpo.length == 8) {
        return '${cepLimpo.substring(0, 5)}-${cepLimpo.substring(5)}';
      }
    }
    return cep;
  }

  void iniciarEdicaoTitulo() {
    editandoTitulo = true;
    onUpdateUI?.call();
  }

  void salvarTitulo() {
    String novoTitulo = tituloEditController.text.trim();
    if (novoTitulo.isNotEmpty && dadosSolicitacao != null) {
      dadosSolicitacao!['titulo'] = novoTitulo;
    }
    editandoTitulo = false;
    onUpdateUI?.call();
  }

  void cancelarEdicaoTitulo() {
    tituloEditController.text = titulo ?? '';
    editandoTitulo = false;
    onUpdateUI?.call();
  }

  void iniciarEdicaoDescricao() {
    editandoDescricao = true;
    onUpdateUI?.call();
  }

  void salvarDescricao() {
    String novaDescricao = descricaoEditController.text.trim();
    if (novaDescricao.isNotEmpty && dadosSolicitacao != null) {
      dadosSolicitacao!['descricao'] = novaDescricao;
    }
    editandoDescricao = false;
    onUpdateUI?.call();
  }

  void cancelarEdicaoDescricao() {
    descricaoEditController.text = descricao ?? '';
    editandoDescricao = false;
    onUpdateUI?.call();
  }

  String formatarData(String? dataISO) {
    if (dataISO == null) return 'N/A';
    return _solicitacaoController.formatarData(dataISO);
  }

  String formatarValor(dynamic valor) {
    if (valor == null) return 'R\$ 0,00';

    try {
      double valorDouble;
      if (valor is String) {
        valorDouble = double.parse(valor);
      } else if (valor is num) {
        valorDouble = valor.toDouble();
      } else {
        return 'R\$ 0,00';
      }

      return 'R\$ ${valorDouble.toStringAsFixed(2).replaceAll('.', ',')}';
    } catch (e) {
      return 'R\$ 0,00';
    }
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> confirmarSolicitacao() async {
    if (dadosSolicitacao == null) return;

    isLoading = true;
    onUpdateUI?.call();

    try {
      final novaSolicitacao = await _solicitacaoController.criarSolicitacao(
        titulo: dadosSolicitacao!['titulo'],
        descricao: dadosSolicitacao!['descricao'],
        categoria: dadosSolicitacao!['servico']['categoria'],
        servico: dadosSolicitacao!['servico'],
        clienteNome: dadosSolicitacao!['cliente']['nome'],
        clienteCpfCnpj: dadosSolicitacao!['cliente']['cpfCnpj'],
        prestadorNome: dadosSolicitacao!['prestador']['nome'],
        prestadorCpfCnpj: dadosSolicitacao!['prestador']['cpfCnpj'],
      );

      print("=== SOLICITAÇÃO SALVA COM SUCESSO ===");
      print("ID: ${novaSolicitacao['id']}");
      print("Título: ${novaSolicitacao['titulo']}");
      print("Status: ${novaSolicitacao['statusSolicitacao']}");
      print("Cliente salvo: nome=${novaSolicitacao['cliente']['nome']}, cpf=${novaSolicitacao['cliente']['cpfCnpj']}");
      print("Prestador salvo: nome=${novaSolicitacao['prestador']['nome']}, cpf=${novaSolicitacao['prestador']['cpfCnpj']}");
      print("Dados completos do prestador estão disponíveis para exibição, mas só nome e CPF foram salvos");
      print("=====================================");

      onShowMessage?.call('Solicitação criada com sucesso!', true);

      await Future.delayed(Duration(seconds: 2));
      onNavigateBack?.call();

    } catch (e) {
      print("Erro ao confirmar solicitação: $e");
      onShowMessage?.call('Erro ao criar solicitação', false);
    } finally {
      isLoading = false;
      onUpdateUI?.call();
    }
  }

  void dispose() {
    tituloEditController.dispose();
    descricaoEditController.dispose();
  }
}