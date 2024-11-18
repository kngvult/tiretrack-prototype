class Truck {
  final String idCaminhao;
  final String emplacamento;
  final String modeloCaminhao;
  final int anoFabricacao;
  final int kmTotal;

  Truck({
    required this.idCaminhao,
    required this.emplacamento,
    required this.modeloCaminhao,
    required this.anoFabricacao,
    required this.kmTotal,
  });

  factory Truck.fromJson(Map<String, dynamic> json) {
    return Truck(
      idCaminhao: json['id_caminhao'],
      emplacamento: json['emplacamento'],
      modeloCaminhao: json['modelo_caminhao'],
      anoFabricacao: json['ano_fabricacao'],
      kmTotal: json['km_total'],
    );
  }
}
