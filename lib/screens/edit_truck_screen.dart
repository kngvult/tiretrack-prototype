import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditTruckScreen extends StatefulWidget {
  final List<Map<String, dynamic>> trucks;
  final Function({
    String? id,
    required String emplacamento,
    required String modelo,
    required int ano,
    required int km,
  }) editTruck;

  const EditTruckScreen({
    Key? key,
    required this.trucks,
    required this.editTruck,
  }) : super(key: key);

  @override
  State<EditTruckScreen> createState() => _EditTruckScreenState();
}

class _EditTruckScreenState extends State<EditTruckScreen> {
  bool isLoading = false;
  Map<String, dynamic>? truckDetails;
  List<Map<String, dynamic>> tires = [];
  final List<String> tirePositions = [
    'DIANTEIRO E',
    'DIANTEIRO D',
    'TRASEIRO E1',
    'TRASEIRO D1',
    'TRASEIRO E2',
    'TRASEIRO D2',
    'TRASEIRO E3',
    'TRASEIRO D3',
    'TRASEIRO E4',
    'TRASEIRO D4',
  ];

  Future<void> fetchTruckDetails(String truckId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final truckResponse = await http
          .get(Uri.parse('http://192.168.100.153:3000/caminhoes/$truckId'));
      final tireResponse = await http
          .get(Uri.parse('http://192.168.100.153:3000/pneus/$truckId'));

      if (truckResponse.statusCode == 200 && tireResponse.statusCode == 200) {
        final truckData = json.decode(truckResponse.body);
        final tireData = json.decode(tireResponse.body);

        setState(() {
          truckDetails = truckData is List && truckData.isNotEmpty
              ? truckData.first
              : truckData;
          tires = List<Map<String, dynamic>>.from(tireData);
          isLoading = false;
        });

        if (truckDetails != null) {
          showEditDialog();
        } else {
          throw Exception('No truck details found');
        }
      } else {
        throw Exception('Failed to load truck details or tires.');
      }
    } catch (e) {
      print('Error fetching truck or tire details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Editar Caminhão - ${truckDetails?['modelo_caminhao'] ?? 'Sem dados'}'),
          content: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildTruckForm(),
                      const SizedBox(height: 20),
                      const Text('Pneus',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(),
                      ...buildTireFormFields(),
                    ],
                  ),
                ),
          actions: [
            ElevatedButton(
              onPressed: () {
                editTruck();
              },
              child: const Text('Salvar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> buildTireFormFields() {
    return tirePositions.map((position) {
      final tire = tires.firstWhere((tire) => tire['posicao'] == position,
          orElse: () => {'posicao': position, 'pneu_id': ''});
      return Column(
        children: [
          ListTile(
            title: Text('Posição: $position'),
            subtitle: TextFormField(
              initialValue: tire['pneu_id'],
              decoration: InputDecoration(labelText: 'ID do Pneu'),
              onChanged: (value) {
                tire['pneu_id'] = value;
                final index = tires.indexWhere((t) => t['posicao'] == position);
                if (index != -1) {
                  tires[index] = tire;
                } else {
                  tires.add(tire);
                }
              },
            ),
          ),
          const Divider(),
        ],
      );
    }).toList();
  }

  Future<void> editTruck() async {
    try {
      final truckId = truckDetails!['id_caminhao'];
      final response = await http.put(
        Uri.parse('http://192.168.100.153:3000/caminhoes/$truckId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'emplacamento': truckDetails!['emplacamento'],
          'modelo_caminhao': truckDetails!['modelo_caminhao'],
          'ano_fabricacao': truckDetails!['ano_fabricacao'],
          'km_total': truckDetails!['km_total'],
        }),
      );

      if (response.statusCode == 200) {
        widget.editTruck(
          id: truckId,
          emplacamento: truckDetails!['emplacamento'],
          modelo: truckDetails!['modelo_caminhao'],
          ano: truckDetails!['ano_fabricacao'],
          km: truckDetails!['km_total'],
        );

        for (var tire in tires) {
          await http.put(
            Uri.parse('http://192.168.100.153:3000/pneus/${tire['pneu_id']}'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(tire),
          );
        }

        Navigator.of(context).pop();
      } else {
        throw Exception('Failed to edit truck');
      }
    } catch (e) {
      print('Erro ao editar caminhão: $e');
    }
  }

  Widget buildTruckForm() {
    if (truckDetails == null) return const SizedBox();

    return Column(
      children: [
        TextFormField(
          initialValue: truckDetails!['emplacamento'],
          decoration: const InputDecoration(labelText: 'Emplacamento'),
          onChanged: (value) {
            truckDetails!['emplacamento'] = value;
          },
        ),
        TextFormField(
          initialValue: truckDetails!['modelo_caminhao'],
          decoration: const InputDecoration(labelText: 'Modelo do Caminhão'),
          onChanged: (value) {
            truckDetails!['modelo_caminhao'] = value;
          },
        ),
        TextFormField(
          initialValue: truckDetails!['ano_fabricacao'].toString(),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Ano de Fabricação'),
          onChanged: (value) {
            truckDetails!['ano_fabricacao'] = int.parse(value);
          },
        ),
        TextFormField(
          initialValue: truckDetails!['km_total'].toString(),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'KM Total'),
          onChanged: (value) {
            truckDetails!['km_total'] = int.parse(value);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Caminhões',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo[800],
      ),
      body: widget.trucks.isEmpty
          ? const Center(child: Text('Nenhum caminhão disponível.'))
          : ListView.builder(
              itemCount: widget.trucks.length,
              itemBuilder: (context, index) {
                final truck = widget.trucks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(
                        '${truck['id_caminhao']} - ${truck['modelo_caminhao']}'),
                    subtitle: Text('Emplacamento: ${truck['emplacamento']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        fetchTruckDetails(truck['id_caminhao']);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
