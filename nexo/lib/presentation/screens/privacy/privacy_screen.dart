import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidade')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _Section(
            title: 'Quais dados coletamos',
            body:
                'Apenas dados que você mesmo insere (hábitos e conclusões), '
                'armazenados localmente no seu dispositivo.',
            onSurface: onSurface,
          ),
          _Section(
            title: 'Como usamos seus dados',
            body:
                'Os dados são usados exclusivamente para exibir seu progresso '
                'e histórico dentro do app.',
            onSurface: onSurface,
          ),
          _Section(
            title: 'Compartilhamento de dados',
            body:
                'Seus dados NÃO são compartilhados com terceiros. A única '
                'comunicação externa é com a API ZenQuotes para buscar citações '
                'motivacionais, que não envia nenhum dado seu.',
            onSurface: onSurface,
          ),
          _Section(
            title: 'Seus direitos (LGPD Art. 18)',
            body:
                '• Acesso: você pode visualizar todos os seus dados dentro do app.\n'
                '• Correção: edite qualquer hábito a qualquer momento.\n'
                '• Exclusão: use "Limpar todos os dados" em Configurações para '
                'apagar permanentemente todas as informações do dispositivo.',
            onSurface: onSurface,
          ),
          _Section(
            title: 'Como excluir seus dados',
            body:
                'Use a opção "Limpar todos os dados" em Configurações. '
                'A ação é irreversível e remove hábitos, histórico e preferências.',
            onSurface: onSurface,
          ),
          _Section(
            title: 'Contato do responsável',
            body: 'Para dúvidas sobre privacidade, entre em contato: '
                'jogustavo.rodrigues@gmail.com',
            onSurface: onSurface,
          ),
          const SizedBox(height: 16),
          Text(
            'Última atualização: junho de 2026',
            style: TextStyle(
              fontSize: 12,
              color: onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  final Color onSurface;

  const _Section({
    required this.title,
    required this.body,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }
}
