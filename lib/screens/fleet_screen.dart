import 'package:flutter/material.dart';
import '../services/api_service.dart' as api;
import '../models/truck.dart' as model;

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});

  @override
  FleetScreenState createState() => FleetScreenState();
}

class FleetScreenState extends State<FleetScreen> {
  late Future<List<model.Truck>> futureTrucks;

  @override
  void initState() {
    super.initState();
    futureTrucks = api.ApiService().fetchTrucks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TireTrack - Frota de Caminhões'),
      ),
      body: FutureBuilder<List<model.Truck>>(
        future: futureTrucks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final trucks = snapshot.data!;
            return ListView.builder(
              itemCount: trucks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(trucks[index].modeloCaminhao),
                  subtitle: Text('Placa: ${trucks[index].emplacamento}'),
                );
              },
            );
          } else {
            return const Center(child: Text('Nenhum caminhão encontrado'));
          }
        },
      ),
    );
  }
}
