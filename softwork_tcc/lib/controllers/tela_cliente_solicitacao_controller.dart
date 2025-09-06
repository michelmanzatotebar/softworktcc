import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../telas/tela_detalhes_solicitacao.dart';

class TelaClienteSolicitacaoController {
  Map<String, dynamic>? prestadorInfo;
  bool isLoading = true;

  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();

  Map<String, dynamic>? dadosSolicitacao;
  Map<String, dynamic>? servicoAtual;

  String? clienteNome;
  String? clienteCpfCnpj;

  void configurarDadosCliente({
    required String nome,
    required String cpfCnpj,
  }) {
    clienteNome = nome;
    clienteCpfCnpj = cpfCnpj;
  }

  Future<void> carregarInformacoesPrestador(
      Map<String, dynamic> servico, {
        required VoidCallback onComplete,
      }) async {
    if (servico['prestador'] != null) {
      try {
        String prestadorCpfCnpj = servico['prestador']['cpfCnpj'] ?? '';

        if (prestadorCpfCnpj.isNotEmpty) {
          final DatabaseReference ref = FirebaseDatabase.instance.ref();
          final snapshot = await ref.child('usuarios/$prestadorCpfCnpj').get();

          if (snapshot.exists) {
            prestadorInfo = Map<String, dynamic>.from(snapshot.value as Map);
          }
        }
      } catch (e) {
        print("Erro ao carregar informações do prestador: $e");
      }
    }

    isLoading = false;
    onComplete();
  }

  String formatarTelefone(String telefone) {
    if (telefone.length == 11) {
      return '(${telefone.substring(0, 2)}) ${telefone.substring(2, 7)}-${telefone.substring(7)}';
    }
    return telefone;
  }

  String formatarValor(dynamic valor) {
    if (valor != null) {
      return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
    }
    return 'R\$ 0,00';
  }

  void revisarSolicitacao(BuildContext context) {
    _criarDadosSolicitacao();

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaDetalhesSolicitacao(dadosSolicitacao: dadosSolicitacao!),
      ),
    );
  }

  void _criarDadosSolicitacao() {
    dadosSolicitacao = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'titulo': tituloController.text.trim(),
      'descricao': descricaoController.text.trim(),
      'dataSolicitacao': DateTime.now().toIso8601String(),
      'statusSolicitacao': 'Pendente',

      'servico': {
        'id': servicoAtual?['id'] ?? '',
        'nome': servicoAtual?['nome'] ?? '',
        'descricao': servicoAtual?['descricao'] ?? '',
        'valor': servicoAtual?['valor'] ?? 0.0,
        'categoria': servicoAtual?['categoria'] ?? '',
      },

      'cliente': {
        'id': 1,
        'nome': clienteNome ?? 'Cliente',
        'telefone': '11999999999',
        'email': 'cliente@email.com',
        'cpfCnpj': clienteCpfCnpj ?? '',
        'tipoConta': true,
        'logradouro': 'Rua Cliente, 123',
        'cep': '12345678',
        'idade': 30,
      },

      'prestador': {
        'id': 1,
        'nome': prestadorInfo?['nome'] ?? servicoAtual?['prestador']?['nome'] ?? '',
        'telefone': prestadorInfo?['telefone'] ?? '',
        'email': prestadorInfo?['email'] ?? '',
        'cpfCnpj': servicoAtual?['prestador']?['cpfCnpj'] ?? '',
        'tipoConta': false,
        'logradouro': prestadorInfo?['logradouro'] ?? '',
        'cep': prestadorInfo?['cep'] ?? '',
        'idade': prestadorInfo?['idade'] ?? 30,
      },
    };
  }

  void limparCampos() {
    tituloController.clear();
    descricaoController.clear();
  }

  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
  }
}