import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String selectedPeriod = 'monthly'; // Default period filter
  Map<String, List<int>> maintenanceRequests = {};
  Map<String, List<int>> recapRequests = {};
  Map<String, List<int>> tireReplacements = {};
  Map<String, List<int>> tireSales = {};

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  void fetchDashboardData() {
    // Aqui, faremos requisições HTTP para buscar os dados de cada gráfico
    // ou usaremos uma função de callback para obter os dados da API existente.
    // Exemplo: mock data
    maintenanceRequests = {
      'monthly': [5, 10, 7, 3, 8, 15],
      'semiannual': [30, 25],
      'annual': [75]
    };
    recapRequests = {
      'monthly': [3, 6, 4, 8, 5, 7],
      'semiannual': [20, 18],
      'annual': [45]
    };
    tireReplacements = {
      'monthly': [2, 5, 3, 6, 2, 8],
      'semiannual': [15, 14],
      'annual': [35]
    };
    tireSales = {
      'monthly': [1, 2, 3, 4, 5, 6],
      'semiannual': [12, 10],
      'annual': [28]
    };
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Período",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: selectedPeriod,
                items: [
                  DropdownMenuItem(child: Text("Mensal"), value: 'monthly'),
                  DropdownMenuItem(
                      child: Text("Semestral"), value: 'semiannual'),
                  DropdownMenuItem(child: Text("Anual"), value: 'annual'),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPeriod = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              buildChart("Requisições de Manutenção",
                  maintenanceRequests[selectedPeriod]!),
              buildChart("Pneus Recapados", recapRequests[selectedPeriod]!),
              buildChart("Pneus Trocados", tireReplacements[selectedPeriod]!),
              buildChart("Pneus Vendidos", tireSales[selectedPeriod]!),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildChart(String title, List<int> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: data
                      .asMap()
                      .entries
                      .map((entry) =>
                          FlSpot(entry.key.toDouble(), entry.value.toDouble()))
                      .toList(),
                  isCurved: true,
                  gradient: LinearGradient(colors: [
                    Colors.blueAccent,
                    Colors.lightBlueAccent,
                  ]),
                  barWidth: 4,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.3),
                        Colors.lightBlueAccent.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    reservedSize: 40,
                    getTitlesWidget: (value, _) => Text(
                      '${value.toInt()}',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                      return Text(labels[value.toInt() % labels.length],
                          style: TextStyle(color: Colors.grey, fontSize: 10));
                    },
                    reservedSize: 40,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
