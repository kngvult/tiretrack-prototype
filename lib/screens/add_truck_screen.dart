import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddTruckScreen extends StatefulWidget {
  const AddTruckScreen({Key? key}) : super(key: key);

  @override
  State<AddTruckScreen> createState() => _AddTruckScreenState();
}

class _AddTruckScreenState extends State<AddTruckScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _emplacamento;
  late String _modelo;
  late int _ano;
  late int _km;
  String _nextTruckId = ''; // Valor padrão

  @override
  void initState() {
    super.initState();
    _initializeTruckId();
  }

  Future<void> _initializeTruckId() async {
    final id = await _generateNextTruckId();
    if (id != null) {
      setState(() {
        _nextTruckId = id;
      });
    } else {
      _showError('Erro ao gerar o próximo ID do caminhão');
    }
  }

  Future<void> addTruck() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.100.153:3000/caminhoes'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id_caminhao': _nextTruckId,
          'emplacamento': _emplacamento,
          'modelo_caminhao': _modelo,
          'ano_fabricacao': _ano,
          'km_total': _km,
        }),
      );

      if (response.statusCode == 201) {
        // Adiciona os pneus
        await addTires();
        Navigator.pop(context);
      } else {
        _showError('Falha ao adicionar caminhão: ${response.body}');
      }
    } catch (e) {
      _showError('Erro ao adicionar caminhão: $e');
    }
  }

  Future<void> addTires() async {
    for (int i = 1; i <= 10; i++) {
      String tireId = '$_emplacamento-P$i';
      Map<String, dynamic> tireData = {
        'pneu_id': tireId,
        'id_caminhao': _nextTruckId,
        'posicao': 'P$i',
        'km_pneu': 0, // Defina um valor padrão ou colete do usuário
        'data_ultima_manutencao': DateTime.now().toIso8601String(),
        'ult_calibragem': DateTime.now().toIso8601String(),
        'km_limite_manutencao':
            10000 // Defina um valor padrão ou colete do usuário
      };

      await http.post(
        Uri.parse('http://192.168.100.153:3000/pneus'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(tireData),
      );
    }
  }

  Future<String?> _generateNextTruckId() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.100.153:3000/caminhoes'));
      if (response.statusCode == 200) {
        final List<dynamic> trucks = json.decode(response.body);
        if (trucks.isNotEmpty) {
          // Obter o último ID de caminhão
          String lastTruckId = trucks.last['id_caminhao'];
          int lastIdNumber = int.tryParse(lastTruckId.substring(3)) ?? 0;

          // Incrementar o ID para o próximo caminhão
          int nextIdNumber = lastIdNumber + 1;
          return 'CAM${nextIdNumber.toString().padLeft(3, '0')}';
        } else {
          // Se não houver caminhões, comece do CAM001
          return 'CAM001';
        }
      } else {
        _showError('Falha ao carregar caminhões: ${response.body}');
        return null;
      }
    } catch (e) {
      _showError('Erro ao carregar caminhões: $e');
      return null;
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Adicionar Caminhão', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo[800],
      ),
      body: _nextTruckId.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Exibir indicador de carregamento
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'ID do Caminhão'),
                          initialValue: _nextTruckId,
                          enabled: false,
                        ),
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: 'Emplacamento'),
                          onSaved: (value) => _emplacamento = value!,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o emplacamento';
                            } else if (!RegExp(r'^[A-Z0-9]{7}$')
                                .hasMatch(value)) {
                              return 'Formato de emplacamento inválido';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Modelo'),
                          onSaved: (value) => _modelo = value!,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o modelo';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Ano'),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _ano = int.parse(value!),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o ano';
                            } else if (int.parse(value) < 1900 ||
                                int.parse(value) > DateTime.now().year) {
                              return 'Ano inválido';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Km Total'),
                          keyboardType: TextInputType.number,
                          onSaved: (value) => _km = int.parse(value!),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o km total';
                            } else if (int.parse(value) < 0) {
                              return 'Km total deve ser positivo';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              addTruck();
                            }
                          },
                          child: Text('Adicionar Caminhão'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
