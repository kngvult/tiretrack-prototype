import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'alertas_screen.dart';
//import 'admin_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdmin;

  HomeScreen({required this.isAdmin});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F4F9),
      appBar: _buildAppBar(),
      body: _buildDashboardBody(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'TireTrack',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          fontFamily: 'Cairo',
        ),
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
      elevation: 5.0,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications,
              color: Colors.white), // Ícone de notificação
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AlertasScreen()), // Redireciona para alertas_screen
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.exit_to_app, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDashboardBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCardGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Color(0xFF4A69BD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF4A69BD), size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bem-vindo(a) ao TireTrack!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                'O seu gerenciador de serviços',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Cairo',
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrid() {
    return Column(
      children: [
        if (widget.isAdmin) // Exibe apenas se for 'admin'
          _buildCard(
            context,
            'Solicitar Ordem de Serviço',
            Icons.assignment_rounded,
            Colors.blue,
            'Solicite a manutenção em caminhões em nossa frota!',
            '/request-service-order',
          ),
        if (widget.isAdmin) // Exibe apenas se for 'admin'
          SizedBox(height: 16),
        _buildCard(
          context,
          'Atender Solicitação',
          Icons.handyman,
          Colors.orange,
          'Informe a manutenção realizada.',
          '/maintenance-record',
        ),
        SizedBox(height: 16),
        _buildCard(
          context,
          'Histórico de Manutenção',
          Icons.settings_backup_restore,
          Colors.green,
          'Verifique todas as manutenções já realizadas.',
          '/maintenance-history',
        ),
        if (widget.isAdmin) // Exibe apenas se for 'admin'
          SizedBox(height: 16),
        if (widget.isAdmin) // Exibe apenas se for 'admin'
          _buildCard(
            context,
            'Gerenciar Frota',
            Icons.fire_truck_rounded,
            Colors.red,
            'Edite/Modifique a sua frota.',
            '/add-truck-tire',
          ),
        if (widget.isAdmin) // Card adicional para o Dashboard
          SizedBox(height: 16),
        if (widget.isAdmin)
          _buildCard(
            context,
            'Dashboard',
            Icons.dashboard,
            Colors.purple,
            'Visualize métricas e estatísticas.',
            '/dashboard',
          ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon,
      Color iconColor, String subtitle, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
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
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 40),
                SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                    fontFamily: 'Cairo',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
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
