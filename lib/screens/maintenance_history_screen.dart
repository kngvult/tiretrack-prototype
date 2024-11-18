import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MaintenanceHistoryScreen extends StatefulWidget {
  @override
  _MaintenanceHistoryScreenState createState() =>
      _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  List<Map<String, dynamic>> finalizedOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFinalizedOrders();
  }

  Future<void> fetchFinalizedOrders() async {
    try {
      final response = await http.get(
          Uri.parse('http://192.168.100.153:3000/ordens_servico/finalizado'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        setState(() {
          finalizedOrders = List<Map<String, dynamic>>.from(responseData);
          isLoading = false;
        });
      } else {
        throw Exception('Falha ao carregar ordens finalizadas');
      }
    } catch (e) {
      print('Erro ao buscar ordens finalizadas: $e');
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Detalhes da Ordem #${order['id_requisicao']}',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.blueAccent),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Caminhão: ${order['id_caminhao']}'),
                Text('Pneu: ${order['pneu_id']}'),
                Text('Descrição: ${order['descricao']}'),
                Text('Observações Adicionais: ${order['obs_adicionais']}'),
                Text('Data da Finalização: ${order['data_manutencao']}'),
                Text('Urgência: ${order['urgencia']}'),
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
        title: Text(
          'Histórico de Manutenções',
          style: TextStyle(color: Colors.white),
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
        elevation: 6.0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : finalizedOrders.isEmpty
              ? Center(
                  child: Text(
                    'Sem históricos de manutenções finalizadas.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: finalizedOrders.length,
                    itemBuilder: (context, index) {
                      final order = finalizedOrders[index];

                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: Colors.white,
                        child: InkWell(
                          onTap: () => _showOrderDetails(order),
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
                                        'Ordem de Serviço: ${order['id_requisicao']}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF333A82),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text('Caminhão: ${order['id_caminhao']}',
                                          style: TextStyle(fontSize: 16)),
                                      SizedBox(height: 4),
                                      Text('Pneu: ${order['pneu_id']}',
                                          style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green),
                                    SizedBox(height: 4),
                                    Text(
                                      'Finalizado',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
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
