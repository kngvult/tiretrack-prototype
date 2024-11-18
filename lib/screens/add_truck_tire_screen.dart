import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'edit_truck_screen.dart';
import 'add_truck_screen.dart';

class AddTruckTireScreen extends StatefulWidget {
  const AddTruckTireScreen({Key? key}) : super(key: key);

  @override
  State<AddTruckTireScreen> createState() => _AddTruckTireScreenState();
}

class _AddTruckTireScreenState extends State<AddTruckTireScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> trucks = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchTrucks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('http://192.168.100.153:3000/caminhoes'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          trucks = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });

        // Navega para a tela de edição de frota, passando os caminhões recebidos.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditTruckScreen(
              trucks: trucks, // Passando os caminhões reais
              editTruck: editTruck,
            ),
          ),
        );
      } else {
        throw Exception('Failed to load trucks');
      }
    } catch (e) {
      print('Error fetching trucks: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void editTruck({
    String? id,
    required String emplacamento,
    required String modelo,
    required int ano,
    required int km,
  }) {
    print('Caminhão editado: $id, $emplacamento, $modelo, $ano, $km');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gerenciar Frota',
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
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: true,
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 24.0, 0.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildOptionCard(
                        icon: Icons.visibility,
                        title: 'Exibir Frota',
                        subtitle: 'Visualize todos os caminhões da sua frota',
                        onTap: () {
                          fetchTrucks(); // Fetch the trucks when the button is tapped
                        },
                      ),
                      const SizedBox(height: 20.0),
                      buildOptionCard(
                        icon: Icons.add_circle,
                        title: 'Adicionar à Frota',
                        subtitle: 'Cadastre novos caminhões na sua frota',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddTruckScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.blue, size: 40),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Cairo',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
