import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _senhaController   = TextEditingController();
  bool _carregando = false;
  bool _verSenha   = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    final sucesso = await ApiService.login(
      _usuarioController.text,
      _senhaController.text,
    );

    setState(() => _carregando = false);

    if (sucesso && mounted) {
      AuthState.logado = true;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Usuário ou senha incorretos.'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.lock_rounded, size: 44, color: Colors.white),
                      SizedBox(height: 10),
                      Text('Área Administrativa',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                      SizedBox(height: 4),
                      Text('Acesso restrito ao administrador',
                        style: TextStyle(fontSize: 13, color: Colors.white70)),
                    ],
                  ),
                ),

                // Formulário
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Usuário',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _usuarioController,
                          decoration: const InputDecoration(
                            hintText: 'Digite seu usuário',
                            prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                          ),
                          validator: (v) => v!.isEmpty ? 'Informe o usuário' : null,
                        ),
                        const SizedBox(height: 18),

                        const Text('Senha',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _senhaController,
                          obscureText: !_verSenha,
                          decoration: InputDecoration(
                            hintText: 'Digite sua senha',
                            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _verSenha ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                size: 20,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _verSenha = !_verSenha),
                            ),
                          ),
                          validator: (v) => v!.isEmpty ? 'Informe a senha' : null,
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _carregando ? null : _login,
                            child: _carregando
                                ? const SizedBox(
                                    height: 20, width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Entrar'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Voltar ao início',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          ),
                        ),
                      ],
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
}