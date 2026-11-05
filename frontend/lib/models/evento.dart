
class Evento {
  Evento({
    required this.id,
    required this.nome,
    required this.dataInicio,
    required this.dataFim,
    required this.local,
  });

  final int id;
  final String nome;
  final String dataInicio;
  final String dataFim;
  final String local;

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'],
      nome: json['nome'],
      dataInicio: json['data_inicio'],
      dataFim: json['data_fim'],
      local: json['local'],
    );
  }
}
