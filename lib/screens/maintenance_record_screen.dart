import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MaintenanceRecordScreen extends StatefulWidget {
  @override
  _MaintenanceRecordScreenState createState() =>
      _MaintenanceRecordScreenState();
}

class _MaintenanceRecordScreenState extends State<MaintenanceRecordScreen> {
  List<Map<String, dynamic>> serviceOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchServiceOrders();
  }

  Future<void> fetchServiceOrders() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.100.153:3000/ordens_servico'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          serviceOrders = List<Map<String, dynamic>>.from(responseData);
          isLoading = false;
        });

        int pendingOrders = serviceOrders
            .where((order) => order['status'] != 'Finalizado')
            .length;
        await savePendingOrdersToPreferences(pendingOrders);
      } else {
        throw Exception('Failed to load service orders');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar ordens de serviço: $e')),
      );
    }
  }

  Future<void> savePendingOrdersToPreferences(int pendingOrders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pendingServiceOrders', pendingOrders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registro de Manutenção',
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
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : serviceOrders.isEmpty
              ? Center(
                  child: Text(
                    'Sem chamados para atendimento.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: serviceOrders.length,
                  itemBuilder: (context, index) {
                    final order = serviceOrders[index];
                    return buildServiceOrderCard(order);
                  },
                ),
    );
  }

  Widget buildServiceOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MaintenanceDetailScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text('Pneu: ${order['pneu_id']}', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

class MaintenanceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const MaintenanceDetailScreen({Key? key, required this.order})
      : super(key: key);

  @override
  _MaintenanceDetailScreenState createState() =>
      _MaintenanceDetailScreenState();
}

class _MaintenanceDetailScreenState extends State<MaintenanceDetailScreen> {
  String? selectedAction;
  String? selectedMaintenance;
  String? selectedSubstitution;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDetailCard(),
                const SizedBox(height: 20),
                buildActionServiceCard(),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await concludeService();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      child: Text(
                        'Concluir Serviço',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
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
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Registro de Manutenção',
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
      elevation: 4.0,
    );
  }

  Widget buildDetailCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalhes da Ordem de Serviço',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[800],
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Ordem de Serviço:',
                widget.order['id_requisicao']?.toString() ?? 'N/A'),
            _buildDetailRow('Identificação do Veículo:',
                widget.order['id_caminhao']?.toString() ?? 'N/A'),
            _buildDetailRow('Pneu para Manutenção:',
                widget.order['pneu_id']?.toString() ?? 'N/A'),
            _buildDetailRow(
              'Urgência:',
              widget.order['urgencia']?.toString() ?? 'N/A',
              isUrgent: true,
            ),
            _buildDetailRow(
              'Data da Requisição:',
              widget.order['data_solicitacao']?.toString() ?? 'N/A',
            ),
            const SizedBox(height: 20),
            Text('Descrição do Problema:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.order['descricao']?.toString() ?? 'N/A',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Text('Observações Adicionais:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.order['obs_adicionais']?.toString() ?? 'Nenhuma',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isUrgent = false}) {
    Color? boxColor;
    Color textColor;

    // Determinando as cores baseadas na urgência
    switch (value) {
      case 'Baixa':
        boxColor = Colors.green[100]; // Cor verde claro para 'Baixa'
        textColor = Colors.green; // Cor do texto verde
        break;
      case 'Média':
        boxColor = Colors.orange[100]; // Cor laranja claro para 'Média'
        textColor = Colors.orange; // Cor do texto laranja
        break;
      case 'Alta':
        boxColor = Colors.red[100]; // Cor vermelha claro para 'Alta'
        textColor = Colors.red; // Cor do texto vermelho
        break;
      default:
        boxColor = Colors.transparent; // Cor padrão se não for urgente
        textColor = Colors.black; // Cor do texto padrão
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (isUrgent)
            Container(
              decoration: BoxDecoration(
                color: boxColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Text(
                value,
                style: TextStyle(color: textColor), // Usando a cor determinada
              ),
            )
          else
            Text(value),
        ],
      ),
    );
  }

  Widget buildActionServiceCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Serviço Realizado',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 20),
            ActionDropdown(
              selectedAction: selectedAction,
              onChanged: (String? value) {
                setState(() {
                  selectedAction = value;
                  selectedMaintenance = null; // Reset
                  selectedSubstitution = null; // Reset
                });
              },
            ),
            const SizedBox(height: 16),
            if (selectedAction == 'Manutenção') ...[
              Text(
                'Escolha a Manutenção',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold), // Ajuste o estilo conforme necessário
              ),
              SizedBox(height: 8), // Espaçamento entre o label e o dropdown
              MaintenanceDropdown(
                selectedMaintenance: selectedMaintenance,
                onChanged: (String? value) {
                  setState(() {
                    selectedMaintenance = value;
                  });
                },
              ),
            ],
            if (selectedAction == 'Substituição') ...[
              Text(
                'Tipo de Substituição',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold), // Ajuste o estilo conforme necessário
              ),
              SizedBox(height: 8), // Espaçamento entre o label e o dropdown
              SubstitutionDropdown(
                selectedSubstituicao: selectedSubstitution,
                onChanged: (String? value) {
                  setState(() {
                    selectedSubstitution = value;
                  });
                },
              ),
            ],
            const SizedBox(height: 16),
            _buildInputField('Calibragem do Pneu (PSI)'),
            const SizedBox(height: 16),
            _buildInputField('Profundidade dos Sulcos (mm)'),
            const SizedBox(height: 16),
            _buildInputField('Observações', maxLines: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String hintText, {int maxLines = 1}) {
    return TextFormField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText:
            hintText, // Aqui trocamos hintText por labelText conforme o código 2
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              15), // Mantemos 15 para os cantos arredondados
        ),
      ),
    );
  }

  Future<void> concludeService() async {
    try {
      final response = await http.put(
        Uri.parse(
            'http://192.168.100.153:3000/ordens_servico/${widget.order['id_requisicao']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN', // Se necessário
        },
        body: jsonEncode({
          'status': 'Finalizado',
          'descricao': 'Ordem de serviço finalizada',
        }),
      );

      if (response.statusCode == 200) {
        print('Ordem de serviço finalizada com sucesso!');
        Navigator.pop(context);
      } else {
        print(
            'Erro ao finalizar serviço: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro inesperado: $e');
    }
  }
}

class ActionDropdown extends StatelessWidget {
  final String? selectedAction;
  final ValueChanged<String?> onChanged;

  const ActionDropdown({required this.selectedAction, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedAction,
      onChanged: onChanged,
      items: const [
        DropdownMenuItem(
          value: 'Manutenção',
          child: Text('Manutenção'),
        ),
        DropdownMenuItem(
          value: 'Substituição',
          child: Text('Substituição'),
        ),
      ],
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      hint: Text('Selecione uma ação'), // Hint adicionada aqui
    );
  }
}

class MaintenanceDropdown extends StatelessWidget {
  final String? selectedMaintenance;
  final ValueChanged<String?> onChanged;

  const MaintenanceDropdown(
      {required this.selectedMaintenance, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedMaintenance,
      onChanged: onChanged,
      items: const [
        DropdownMenuItem(
          value: 'Concerto do Pneu',
          child: Text('Concerto do Pneu'),
        ),
        DropdownMenuItem(
          value: 'Alinhamento',
          child: Text('Alinhamento'),
        ),
        DropdownMenuItem(
          value: 'Recapagem',
          child: Text('Recapagem'),
        ),
      ],
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      hint: Text('Selecione a manutenção'), // Hint adicionada aqui
    );
  }
}

class SubstitutionDropdown extends StatelessWidget {
  final String? selectedSubstituicao;
  final ValueChanged<String?> onChanged;

  const SubstitutionDropdown(
      {required this.selectedSubstituicao, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedSubstituicao,
      onChanged: onChanged,
      items: const [
        DropdownMenuItem(
          value: 'Rodízo',
          child: Text('Rodízo'),
        ),
        DropdownMenuItem(
          value: 'Estoque',
          child: Text('Estoque'),
        ),
        DropdownMenuItem(
          value: 'Vendido',
          child: Text('Vendido'),
        ),
        DropdownMenuItem(
          value: 'Sucateado',
          child: Text('Sucateado'),
        )
      ],
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      hint: Text('Selecione o tipo de substituição'), // Hint adicionada aqui
    );
  }
}
