import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestServiceOrderScreen extends StatefulWidget {
  const RequestServiceOrderScreen({Key? key}) : super(key: key);

  @override
  _RequestServiceOrderScreenState createState() =>
      _RequestServiceOrderScreenState();
}

class _RequestServiceOrderScreenState extends State<RequestServiceOrderScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String? selectedCaminhao;
  String? selectedPneu;
  final TextEditingController problemDescriptionController =
      TextEditingController();
  final TextEditingController additionalNotesController =
      TextEditingController();

  List<dynamic> caminhoes = [];
  List<dynamic> pneus = [];

  String? selectedUrgency;
  DateTime? preferredDate;

  @override
  void initState() {
    super.initState();
    fetchCaminhoes();
  }

  Future<void> fetchCaminhoes() async {
    final response =
        await http.get(Uri.parse('http://192.168.100.153:3000/caminhoes'));
    if (response.statusCode == 200) {
      setState(() {
        caminhoes = json.decode(response.body);
      });
    } else {
      throw Exception('Falha ao carregar caminhões');
    }
  }

  Future<void> fetchPneus(String idCaminhao) async {
    final response = await http
        .get(Uri.parse('http://192.168.100.153:3000/pneus/$idCaminhao'));
    if (response.statusCode == 200) {
      setState(() {
        pneus = json.decode(response.body);
      });
    } else {
      throw Exception('Falha ao carregar pneus');
    }
  }

  Future<void> sendServiceOrder() async {
    if (selectedCaminhao != null &&
        selectedPneu != null &&
        problemDescriptionController.text.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://192.168.100.153:3000/ordens_servico'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id_caminhao': selectedCaminhao,
          'pneu_id': selectedPneu,
          'descricao': problemDescriptionController.text,
          'data_preferida': preferredDate?.toIso8601String(),
          'urgencia': selectedUrgency,
          'status': 'Pendente'
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ordem de Serviço criada com sucesso!'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(
            context); // Finaliza o chamado e retorna para a tela anterior
      } else {
        throw Exception('Falha ao abrir chamado');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Preencha todos os campos para abrir o chamado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[100],
        appBar: _buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preencha os detalhes da solicitação',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[800],
                      ),
                    ),
                    SizedBox(height: 15),
                    _buildDropdownField<String>(
                      labelText: 'Selecione o Caminhão',
                      value: selectedCaminhao,
                      items:
                          caminhoes.map<DropdownMenuItem<String>>((caminhao) {
                        return DropdownMenuItem<String>(
                          value: caminhao['id_caminhao'],
                          child: Text(
                              '${caminhao['id_caminhao']} - ${caminhao['modelo_caminhao']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCaminhao = value;
                          selectedPneu = null;
                          if (value != null) fetchPneus(value);
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _buildDropdownField<String>(
                      labelText: 'Selecione o Pneu',
                      value: selectedPneu,
                      items: pneus.map<DropdownMenuItem<String>>((pneu) {
                        return DropdownMenuItem<String>(
                          value: pneu['pneu_id'],
                          child:
                              Text('${pneu['pneu_id']} - ${pneu['posicao']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPneu = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      label: 'Descrição do Problema',
                      controller: problemDescriptionController,
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    _buildDatePicker(context),
                    _buildUrgencyChips(),
                    _buildTextField(
                      label: 'Observações Adicionais',
                      controller: additionalNotesController,
                      maxLines: 4,
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: sendServiceOrder,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          child: Text(
                            'Enviar Solicitação',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white), // Texto em branco
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Solicitação de Serviço',
        style:
            TextStyle(color: Colors.white), // Define a cor do texto como branco
      ),
      centerTitle: true,
      backgroundColor: Colors.indigo[800],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[700]!, Colors.indigo[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 4.0,
    );
  }

  Widget _buildDropdownField<T>({
    required String labelText,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(labelText),
      onChanged: onChanged,
      items: items,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      isExpanded: true,
    );
  }

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );

          if (pickedDate != null) {
            setState(() {
              preferredDate = pickedDate;
            });
          }
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.indigo),
              SizedBox(width: 8),
              Text(
                preferredDate != null
                    ? "${preferredDate?.day}/${preferredDate?.month}/${preferredDate?.year}"
                    : "Selecionar Data",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgencyChips() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 10.0,
        children: [
          ChoiceChip(
            label: Text('Baixa'),
            selected: selectedUrgency == 'Baixa',
            onSelected: (selected) {
              setState(() {
                selectedUrgency = selected ? 'Baixa' : null;
              });
            },
            selectedColor: Colors.green[300],
            backgroundColor: Colors.grey[200],
          ),
          ChoiceChip(
            label: Text('Média'),
            selected: selectedUrgency == 'Média',
            onSelected: (selected) {
              setState(() {
                selectedUrgency = selected ? 'Média' : null;
              });
            },
            selectedColor: Colors.orange[300],
            backgroundColor: Colors.grey[200],
          ),
          ChoiceChip(
            label: Text('Alta'),
            selected: selectedUrgency == 'Alta',
            onSelected: (selected) {
              setState(() {
                selectedUrgency = selected ? 'Alta' : null;
              });
            },
            selectedColor: Colors.red[300],
            backgroundColor: Colors.grey[200],
          ),
        ],
      ),
    );
  }
}
