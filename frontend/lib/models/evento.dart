
class Evento {
  Evento({
    required this.id,
    required this.nome,
    required this.data_inicio,
    required this.data_fim,
    required this.local,
  });

  final int id;
  final String nome;
  final String data_inicio;
  final String data_fim;
  final String local;

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'],
      nome: json['nome'],
      data_inicio: json['data_inicio'],
      data_fim: json['data_fim'],
      local: json['local'],
    );
  }
}
