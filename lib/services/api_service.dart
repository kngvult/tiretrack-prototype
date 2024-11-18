import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/truck.dart';
import '../models/tire.dart';

class ApiService {
  final String baseUrl = 'http://192.168.100.153:3000';

  Future<List<Truck>> fetchTrucks() async {
    final response = await http.get(Uri.parse('$baseUrl/caminhoes'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Truck.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load trucks');
    }
  }

  Future<List<Tire>> fetchTires() async {
    final response = await http.get(Uri.parse('$baseUrl/pneus'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Tire.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tires');
    }
  }

  Future<void> addTruck(String modeloCaminhao) async {
    final response = await http.post(
      Uri.parse('$baseUrl/caminhoes'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'modeloCaminhao': modeloCaminhao,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add truck');
    }
  }

  Future<void> addTire(String truckId, String tireId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pneus'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'truckId': truckId,
        'tireId': tireId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add tire');
    }
  }
}
