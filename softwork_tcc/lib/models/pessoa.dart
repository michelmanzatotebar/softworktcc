class Pessoa {
  int id;
  String nome;
  String telefone;
  String senha;
  String email;
  String cpfCnpj;
  bool tipoConta;
  String logradouro;
  String cep;
  int idade;

  Pessoa({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.senha,
    required this.email,
    required this.cpfCnpj,
    required this.tipoConta,
    required this.logradouro,
    required this.cep,
    required this.idade,
  });

  Pessoa.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        nome = map['nome'],
        telefone = map['telefone'],
        senha = map['senha'],
        email = map['email'],
        cpfCnpj = map['cpfCnpj'],
        tipoConta = map['tipoConta'],
        logradouro = map['logradouro'],
        cep = map['cep'],
        idade = map['idade'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'senha': senha,
      'email': email,
      'cpfCnpj': cpfCnpj,
      'tipoConta': tipoConta,
      'logradouro': logradouro,
      'cep': cep,
      'idade': idade,
    };
  }
}