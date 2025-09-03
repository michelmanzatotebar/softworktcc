import 'package:firebase_database/firebase_database.dart';

class ServicosController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  static const List<String> categoriasPredefinidas = [
    'Casa e Manutenção',
    'Limpeza e Organização',
    'Cuidados Pessoais',
    'Pet Services',
    'Tecnologia e Digital',
    'Beleza e Estética',
    'Transporte e Entrega',
    'Alimentação e Gastronomia',
    'Eventos e Entretenimento',
    'Educação e Ensino',
    'Consultoria e Assessoria',
    'Jardim e Paisagismo',
    'Saúde e Bem-estar',
    'Arte e Criação',
    'Serviços Automotivos',
    'Serviços Administrativos',
    'Serviços de Emergência',
  ];

  Future<List<Map<String, dynamic>>> carregarServicosPorPrestador(String cpfCnpj) async {
    try {
      final snapshot = await _ref.child('servicos').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> servicosData = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> servicosDoUsuario = [];

        servicosData.forEach((key, value) {
          Map<String, dynamic> servico = Map<String, dynamic>.from(value);
          servico['id'] = key;

          if (servico['prestador'] != null &&
              servico['prestador']['cpfCnpj'].toString() == cpfCnpj) {
            servicosDoUsuario.add(servico);
          }
        });

        print("Serviços carregados com sucesso");
        return servicosDoUsuario;
      } else {
        print("Serviços carregados com sucesso");
        return [];
      }
    } catch (e) {
      print("Erro ao carregar serviços");
      throw Exception("Erro ao carregar serviços: $e");
    }
  }

  String? validarCampos({
    required String nome,
    required String descricao,
    required String valor,
    required String categoria,
  }) {
    if (nome.trim().isEmpty) {
      return "Por favor, preencha o nome do serviço";
    }

    if (descricao.trim().isEmpty) {
      return "Por favor, preencha a descrição do serviço";
    }

    if (valor.trim().isEmpty) {
      return "Por favor, preencha o valor do serviço";
    }

    if (categoria.trim().isEmpty) {
      return "Por favor, selecione uma categoria";
    }

    if (!categoriasPredefinidas.contains(categoria)) {
      return "Por favor, selecione uma categoria válida";
    }

    try {
      double.parse(valor.trim().replaceAll(',', '.'));
    } catch (e) {
      return "Por favor, insira um valor numérico válido";
    }

    return null;
  }

  Future<Map<String, dynamic>> cadastrarServico({
    required String nome,
    required String descricao,
    required String valor,
    required String categoria,
    required String prestadorCpfCnpj,
    required String prestadorNome,
  }) async {
    try {
      String? erro = validarCampos(
        nome: nome,
        descricao: descricao,
        valor: valor,
        categoria: categoria,
      );

      if (erro != null) {
        throw Exception(erro);
      }

      String servicoId = _ref.child('servicos').push().key!;

      Map<String, dynamic> novoServico = {
        'id': servicoId,
        'nome': nome.trim(),
        'descricao': descricao.trim(),
        'valor': double.parse(valor.trim().replaceAll(',', '.')),
        'categoria': categoria.trim(),
        'prestador': {
          'cpfCnpj': prestadorCpfCnpj,
          'nome': prestadorNome,
        },
      };

      await _ref.child('servicos/$servicoId').set(novoServico);

      return novoServico;

    } catch (e) {
      throw Exception("Erro ao cadastrar serviço: ${e.toString()}");
    }
  }

  Future<void> atualizarServico({
    required String servicoId,
    required String nome,
    required String descricao,
    required String valor,
    required String categoria,
  }) async {
    try {
      String? erro = validarCampos(
        nome: nome,
        descricao: descricao,
        valor: valor,
        categoria: categoria,
      );

      if (erro != null) {
        throw Exception(erro);
      }

      Map<String, dynamic> dadosAtualizados = {
        'nome': nome.trim(),
        'descricao': descricao.trim(),
        'valor': double.parse(valor.trim().replaceAll(',', '.')),
        'categoria': categoria.trim(),
      };

      await _ref.child('servicos/$servicoId').update(dadosAtualizados);

    } catch (e) {
      throw Exception("Erro ao atualizar serviço: ${e.toString()}");
    }
  }

  Future<void> excluirServico(String servicoId) async {
    try {
      await _ref.child('servicos/$servicoId').remove();
    } catch (e) {
      throw Exception("Erro ao excluir serviço: ${e.toString()}");
    }
  }

  Future<Map<String, dynamic>?> buscarServicoPorId(String servicoId) async {
    try {
      final snapshot = await _ref.child('servicos/$servicoId').get();

      if (snapshot.exists) {
        Map<String, dynamic> servico = Map<String, dynamic>.from(snapshot.value as Map);
        servico['id'] = servicoId;
        return servico;
      }

      return null;
    } catch (e) {
      throw Exception("Erro ao buscar serviço: ${e.toString()}");
    }
  }

  Future<List<Map<String, dynamic>>> buscarServicosPorCategoria(String categoria) async {
    try {
      final snapshot = await _ref.child('servicos').get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> servicosData = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> servicosPorCategoria = [];

        servicosData.forEach((key, value) {
          Map<String, dynamic> servico = Map<String, dynamic>.from(value);
          servico['id'] = key;

          if (servico['categoria']?.toString().toLowerCase() == categoria.toLowerCase()) {
            servicosPorCategoria.add(servico);
          }
        });

        return servicosPorCategoria;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception("Erro ao buscar serviços por categoria: ${e.toString()}");
    }
  }
}