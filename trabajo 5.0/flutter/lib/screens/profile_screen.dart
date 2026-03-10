import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/bet_provider.dart';
import '../providers/bet_provider.dart' as bp;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBets() async {
    await context.read<BetProvider>().loadBetsHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, BetProvider>(
      builder: (context, authProvider, betProvider, child) {
        final user = authProvider.user;
        final bets = betProvider.bets;

        return RefreshIndicator(
          onRefresh: () async {
            await authProvider.refreshProfile();
            await _loadBets();
          },
          color: const Color(0xFF22C55E),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildProfileHeader(user),
              ),
              SliverToBoxAdapter(
                child: _buildStats(authProvider, bets),
              ),
              SliverToBoxAdapter(
                child: _buildTabs(),
              ),
              SliverFillRemaining(
                child: _buildBetsList(bets, betProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFF22C55E),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Usuario',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Balance: \$${user?.balance.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(AuthProvider authProvider, List<bp.Bet> bets) {
    final wonBets = bets.where((b) => b.status == 'won').length;
    final lostBets = bets.where((b) => b.status == 'lost').length;
    final totalAmount = bets.fold(0.0, (sum, b) => sum + b.amount);
    final totalWon = bets.where((b) => b.status == 'won').fold(0.0, (sum, b) => sum + b.potentialWin);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.trophy,
              label: 'Ganadas',
              value: wonBets.toString(),
              color: const Color(0xFF22C55E),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.close,
              label: 'Perdidas',
              value: lostBets.toString(),
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.attach_money,
              label: 'Total',
              value: '\$${totalAmount.toStringAsFixed(0)}',
              color: const Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF22C55E),
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: const Color(0xFF22C55E),
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: (index) {
          setState(() {
            switch (index) {
              case 0:
                _currentFilter = 'all';
                break;
              case 1:
                _currentFilter = 'pending';
                break;
              case 2:
                _currentFilter = 'won';
                break;
              case 3:
                _currentFilter = 'lost';
                break;
            }
          });
          context.read<BetProvider>().loadBetsHistory(status: _currentFilter == 'all' ? null : _currentFilter);
        },
        tabs: const [
          Tab(text: 'Todas'),
          Tab(text: 'Pendientes'),
          Tab(text: 'Ganadas'),
          Tab(text: 'Perdidas'),
        ],
      ),
    );
  }

  Widget _buildBetsList(List<bp.Bet> bets, BetProvider betProvider) {
    if (bets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ticket_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay apuestas',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bets.length,
      itemBuilder: (context, index) {
        final bet = bets[index];
        return _buildBetItem(bet, betProvider);
      },
    );
  }

  Widget _buildBetItem(bp.Bet bet, BetProvider betProvider) {
    Color statusColor;
    String statusText;

    switch (bet.status) {
      case 'won':
        statusColor = const Color(0xFF22C55E);
        statusText = 'Ganada';
        break;
      case 'lost':
        statusColor = Colors.red;
        statusText = 'Perdida';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pendiente';
    }

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
                    bet.match != null
                        ? '${bet.match['homeTeam']} vs ${bet.match['awayTeam']}'
                        : 'Partido',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${betProvider.getBetTypeName(bet.betType)} - ${bet.selection}',
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
                  '\$${bet.amount.toStringAsFixed(2)} @ ${bet.odds.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${bet.potentialWin.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
