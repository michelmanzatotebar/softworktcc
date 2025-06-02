import 'pessoa.dart';
import 'solicitacao.dart';

class Cliente extends Pessoa {
  Solicitacao? solicitacao;

  Cliente({
    required super.id,
    required super.nome,
    required super.telefone,
    required super.senha,
    required super.email,
    required super.cpfCnpj,
    required super.tipoConta,
    required super.idade,
    this.solicitacao,
  });

  Cliente.fromMap(Map<String, dynamic> map)
      : solicitacao = map['solicitacao'] != null
      ? Solicitacao.fromMap(map['solicitacao'])
      : null,
        super.fromMap(map);

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['solicitacao'] = solicitacao?.toMap();
    return map;
  }
}