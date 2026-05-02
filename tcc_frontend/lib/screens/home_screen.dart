import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sucesso = ModalRoute.of(context)?.settings.arguments as bool? ?? false;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 480),
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
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.school_rounded, size: 56, color: Colors.white),
                            SizedBox(height: 12),
                            Text('SOS Academy work',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              )),
                            SizedBox(height: 4),
                            Text('Análise e orientação',
                              style: TextStyle(fontSize: 14, color: Colors.white70)),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            if (sucesso) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFF81C784)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 20),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text('Solicitação enviada com sucesso!',
                                        style: TextStyle(
                                          color: Color(0xFF1B5E20),
                                          fontWeight: FontWeight.w600,
                                        )),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            const Text('Olá, como posso ajuda-lo!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              )),
                            const SizedBox(height: 8),
                            Text(
                              'Registre sua solicitação para a análise do seu trabalho academico.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                            ),
                            const SizedBox(height: 32),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(context, '/cadastro'),
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                                label: const Text('Registrar Novo Chamado'),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(children: [
                              Expanded(child: Divider(color: Colors.grey.shade200)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('ou', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade200)),
                            ]),

                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.pushNamed(context, '/login'),
                                icon: const Icon(Icons.admin_panel_settings_rounded, size: 20),
                                label: const Text('Acesso Administrativo'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF2E7D32),
                                  side: const BorderSide(color: Color(0xFF2E7D32)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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