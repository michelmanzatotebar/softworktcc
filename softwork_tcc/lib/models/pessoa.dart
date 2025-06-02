class Pessoa {
  int id;
  String nome;
  int telefone;
  String senha;
  String email;
  int cpfCnpj;
  bool tipoConta;
  int idade;

  Pessoa({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.senha,
    required this.email,
    required this.cpfCnpj,
    required this.tipoConta,
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
      'idade': idade,
    };
  }
}