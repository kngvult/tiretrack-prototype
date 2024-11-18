import 'package:flutter/material.dart';
import 'home_screen.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: CustomWaveClipper(),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo[700]!, Colors.indigo[900]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          ClipPath(
            clipper: CustomWaveClipper(),
            child: Container(
              color: const Color.fromRGBO(
                  40, 53, 147, 0.85), // Cor de fundo primária
            ),
          ),
          SafeArea(
            child: Center(
              child: isSmallScreen
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _Logo(),
                        SizedBox(height: 24),
                        _FormContent(),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.all(32.0),
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Row(
                        children: const [
                          Expanded(child: _Logo()),
                          Expanded(
                            child: Center(child: _FormContent()),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 100);
    path.quadraticBezierTo(
        size.width / 4, size.height - 30, size.width / 2, size.height - 100);
    path.quadraticBezierTo(
        size.width * 3 / 4, size.height - 130, size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomWaveClipper oldClipper) => false;
}

class _Logo extends StatelessWidget {
  const _Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              image: const DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage('assets/icon/tiretrack_v2.png'),
              ),
              borderRadius: BorderRadius.circular(60),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            "Bem-vindo(a) ao TireTrack",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          "Faça login para gerenciar sua frota e manutenções",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }
}

class _FormContent extends StatefulWidget {
  const _FormContent({Key? key}) : super(key: key);

  @override
  State<_FormContent> createState() => __FormContentState();
}

class __FormContentState extends State<_FormContent> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _loginFailed = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final List<Map<String, String>> users = [
    {"username": "admin", "password": "admin123"},
    {"username": "user", "password": "user123"}
  ];

  void _login(BuildContext context) {
    String username = _userController.text;
    String password = _passwordController.text;

    bool isValidUser = users.any(
        (user) => user['username'] == username && user['password'] == password);

    if (isValidUser) {
      bool isAdmin = username == 'admin';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(isAdmin: isAdmin),
        ),
      );
    } else {
      setState(() {
        _loginFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              color: Colors.transparent,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _userController,
                      decoration: InputDecoration(
                        labelText: 'Usuário',
                        hintText: 'Digite seu nome de usuário',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um nome de usuário';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: 'Digite sua senha',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira uma senha';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: _rememberMe,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _rememberMe = value;
                        });
                      },
                      title: const Text('Lembrar-me'),
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      contentPadding: const EdgeInsets.all(0),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF303F9F),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _login(context);
                          }
                        },
                      ),
                    ),
                    if (_loginFailed)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Usuário ou senha inválidos',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
