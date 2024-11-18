import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlertasScreen extends StatefulWidget {
  @override
  _AlertasScreenState createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  List<dynamic> alertas = [];
  final int kmLimiteInferior = 47000;
  final int kmLimiteSuperior = 50000;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAlertas();
  }

  Future<void> fetchAlertas() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.100.153:3000/pneus'));
      if (response.statusCode == 200) {
        List<dynamic> pneus = json.decode(response.body);
        List<dynamic> pneusFiltrados = pneus.where((pneu) {
          final int kmPneu = pneu['km_pneu'];
          return kmPneu >= kmLimiteInferior && kmPneu <= kmLimiteSuperior;
        }).toList();

        setState(() {
          alertas = pneusFiltrados;
          isLoading = false;
        });
      } else {
        throw Exception('Falha ao carregar alertas');
      }
    } catch (e) {
      print(e);
    }
  }

  void _showAlertDetail(dynamic alerta) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Detalhes do Alerta',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Pneu ID: ${alerta['pneu_id']}'),
                Text('Caminhão ID: ${alerta['id_caminhao']}'),
                Text('Km do Pneu: ${alerta['km_pneu']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alertas de Manutenção',
            style: TextStyle(color: Colors.white)),
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
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : alertas.isEmpty
              ? Center(
                  child: Text(
                    'Sem alertas disponíveis.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: alertas.length,
                    itemBuilder: (context, index) {
                      final alerta = alertas[index];

                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white,
                        child: InkWell(
                          onTap: () => _showAlertDetail(alerta),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pneu ID: ${alerta['pneu_id']}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF333A82),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                          'Caminhão ID: ${alerta['id_caminhao']}',
                                          style: TextStyle(fontSize: 16)),
                                      SizedBox(height: 4),
                                      Text('Km do Pneu: ${alerta['km_pneu']}',
                                          style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.warning, color: Colors.red),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
