import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bet_provider.dart';
import '../providers/auth_provider.dart';

class BetSlipScreen extends StatefulWidget {
  const BetSlipScreen({super.key});

  @override
  State<BetSlipScreen> createState() => _BetSlipScreenState();
}

class _BetSlipScreenState extends State<BetSlipScreen> {
  final _amountController = TextEditingController(text: '10');
  double _amount = 10;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.ticket_alt, color: Color(0xFF22C55E)),
            SizedBox(width: 8),
            Text('Ticket de Apuestas'),
          ],
        ),
        actions: [
          Consumer<BetProvider>(
            builder: (context, betProvider, child) {
              if (betProvider.betSlip.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () {
                  betProvider.clearBetSlip();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Limpiar',
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<BetProvider>(
        builder: (context, betProvider, child) {
          if (betProvider.betSlip.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.ticket_alt, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay apuestas en el ticket',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: betProvider.betSlip.length,
                  itemBuilder: (context, index) {
                    final item = betProvider.betSlip[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.homeTeam} vs ${item.awayTeam}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${betProvider.getBetTypeName(item.betType)} - ${item.selection}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '@${item.odds.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF22C55E),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    betProvider.removeFromBetSlip(index);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _buildFooter(betProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFooter(BetProvider betProvider) {
    final potentialWin = betProvider.calculatePotentialWin(_amount);
    final user = context.read<AuthProvider>().user;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cuota Total:',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  betProvider.totalOdds.toStringAsFixed(2),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Monto:',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _amount = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Premio Potential:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '\$${potentialWin.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF22C55E),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Balance disponible: \$${user?.balance.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _amount > 0 && _amount <= (user?.balance ?? 0)
                    ? () => _placeBet(betProvider)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: betProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirmar Apuesta',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeBet(BetProvider betProvider) async {
    final authProvider = context.read<AuthProvider>();
    
    if (_amount > (authProvider.user?.balance ?? 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo insuficiente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await betProvider.placeBet(_amount);

    if (success && mounted) {
      await authProvider.refreshProfile();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apuesta confirmada!'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
    } else if (mounted && betProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(betProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
