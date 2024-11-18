class Tire {
  final String pneuId;
  final String idCaminhao;
  final String posicao;
  final int kmPneu;
  final DateTime dataUltimaManutencao;

  Tire({
    required this.pneuId,
    required this.idCaminhao,
    required this.posicao,
    required this.kmPneu,
    required this.dataUltimaManutencao,
  });

  factory Tire.fromJson(Map<String, dynamic> json) {
    return Tire(
      pneuId: json['pneu_id'],
      idCaminhao: json['id_caminhao'],
      posicao: json['posicao'],
      kmPneu: json['km_pneu'],
      dataUltimaManutencao: DateTime.parse(json['data_ultima_manutencao']),
    );
  }
}
