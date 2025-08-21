import 'package:firebase_database/firebase_database.dart';

class ServicosPesquisaController {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  Function(bool)? onLoadingChanged;
  Function(List<Map<String, dynamic>>)? onResultsChanged;
  Function(List<String>)? onCategoriasChanged;
  Function(String)? onError;

  void setCallbacks({
    Function(bool)? loadingCallback,
    Function(List<Map<String, dynamic>>)? resultsCallback,
    Function(List<String>)? categoriasCallback,
    Function(String)? errorCallback,
  }) {
    onLoadingChanged = loadingCallback;
    onResultsChanged = resultsCallback;
    onCategoriasChanged = categoriasCallback;
    onError = errorCallback;
  }

  Future<void> pesquisarServicos(String query, {String? categoriaFiltro}) async {
    print("Pesquisando serviços: $query | Categoria: $categoriaFiltro");

    if (query.trim().isEmpty && categoriaFiltro == null) {
      onLoadingChanged?.call(false);
      onResultsChanged?.call([]);
      return;
    }

    onLoadingChanged?.call(true);

    try {
      List<Map<String, dynamic>> servicos = await _buscarServicosNoFirebase(query, categoriaFiltro);

      onLoadingChanged?.call(false);
      onResultsChanged?.call(servicos);

    } catch (e) {
      onLoadingChanged?.call(false);
      onResultsChanged?.call([]);
      onError?.call("Erro ao pesquisar serviços");

      print("Erro na pesquisa: $e");
    }
  }

  Future<void> carregarCategorias() async {
    try {
      List<String> categorias = await _buscarCategoriasNoFirebase();
      onCategoriasChanged?.call(categorias);
    } catch (e) {
      print("Erro ao carregar categorias: $e");
      onError?.call("Erro ao carregar categorias");
    }
  }

  Future<List<Map<String, dynamic>>> _buscarServicosNoFirebase(String query, String? categoriaFiltro) async {
    final snapshot = await _ref.child('servicos').get();

    if (!snapshot.exists) {
      print("Nenhum serviço encontrado no banco de dados");
      return [];
    }

    Map<dynamic, dynamic> servicosData = snapshot.value as Map<dynamic, dynamic>;
    List<Map<String, dynamic>> servicosEncontrados = [];

    servicosData.forEach((servicoId, servicoData) {
      Map<String, dynamic> servico = Map<String, dynamic>.from(servicoData);
      servico['id'] = servicoId;

      String nomeServico = servico['nome']?.toString().toLowerCase() ?? '';
      String categoriaServico = servico['categoria']?.toString().toLowerCase() ?? '';
      String queryLower = query.toLowerCase();

      bool matchQuery = query.trim().isEmpty || nomeServico.contains(queryLower);
      bool matchCategoria = categoriaFiltro == null ||
          categoriaFiltro.isEmpty ||
          categoriaServico == categoriaFiltro.toLowerCase();

      if (matchQuery && matchCategoria) {
        // Formatando valor para exibição
        if (servico['valor'] != null) {
          servico['valorFormatado'] = 'R\$ ${servico['valor'].toStringAsFixed(2).replaceAll('.', ',')}';
        }

        // Informações do prestador
        if (servico['prestador'] != null) {
          servico['prestadorNome'] = servico['prestador']['nome'] ?? '';
          servico['prestadorCpfCnpj'] = servico['prestador']['cpfCnpj'] ?? '';
        }

        servicosEncontrados.add(servico);
      }
    });

    // Ordenar por nome do serviço
    servicosEncontrados.sort((a, b) =>
        a['nome'].toString().toLowerCase().compareTo(b['nome'].toString().toLowerCase())
    );

    print("Serviços encontrados: ${servicosEncontrados.length}");
    return servicosEncontrados;
  }

  Future<List<String>> _buscarCategoriasNoFirebase() async {
    final snapshot = await _ref.child('servicos').get();

    if (!snapshot.exists) {
      return [];
    }

    Map<dynamic, dynamic> servicosData = snapshot.value as Map<dynamic, dynamic>;
    Set<String> categoriasSet = {};

    servicosData.forEach((servicoId, servicoData) {
      Map<String, dynamic> servico = Map<String, dynamic>.from(servicoData);

      if (servico['categoria'] != null && servico['categoria'].toString().trim().isNotEmpty) {
        categoriasSet.add(servico['categoria'].toString().trim());
      }
    });

    List<String> categorias = categoriasSet.toList();
    categorias.sort(); // Ordenar alfabeticamente

    print("Categorias encontradas: ${categorias.length}");
    return categorias;
  }

  Future<Map<String, dynamic>?> buscarServicoPorId(String servicoId) async {
    try {
      final snapshot = await _ref.child('servicos/$servicoId').get();

      if (snapshot.exists) {
        Map<String, dynamic> servico = Map<String, dynamic>.from(snapshot.value as Map);
        servico['id'] = servicoId;

        // Formatando valor para exibição
        if (servico['valor'] != null) {
          servico['valorFormatado'] = 'R\$ ${servico['valor'].toStringAsFixed(2).replaceAll('.', ',')}';
        }

        return servico;
      }

      return null;
    } catch (e) {
      print("Erro ao buscar serviço: $e");
      throw Exception("Erro ao buscar serviço: $e");
    }
  }
}