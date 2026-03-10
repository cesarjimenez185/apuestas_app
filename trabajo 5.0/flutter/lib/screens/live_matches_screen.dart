import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/match_provider.dart';
import '../providers/bet_provider.dart';

class LiveMatchesScreen extends StatefulWidget {
  const LiveMatchesScreen({super.key});

  @override
  State<LiveMatchesScreen> createState() => _LiveMatchesScreenState();
}

class _LiveMatchesScreenState extends State<LiveMatchesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().loadLiveMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (context, matchProvider, child) {
        if (matchProvider.liveMatches.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => matchProvider.loadLiveMatches(),
          color: const Color(0xFF22C55E),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matchProvider.liveMatches.length,
            itemBuilder: (context, index) {
              return LiveMatchCard(
                match: matchProvider.liveMatches[index],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.live_tv_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay partidos en vivo',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Los partidos en vivo aparecerán aquí',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class LiveMatchCard extends StatelessWidget {
  final Match match;

  const LiveMatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final betProvider = context.read<BetProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      match.league,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${match.minute}'",
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Icon(Icons.sports_soccer, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        match.homeTeam,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${match.homeScore} - ${match.awayScore}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(Icons.sports_soccer, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        match.awayTeam,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (match.stats != null) ...[
              const SizedBox(height: 20),
              _buildStats(context),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildOddsSection(context, betProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final stats = match.stats!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildStatRow('Posesión', '${stats.possessionHome}%', '${stats.possessionAway}%'),
          const SizedBox(height: 8),
          _buildStatRow('Tiros', '${stats.shotsHome}', '${stats.shotsAway}'),
          const SizedBox(height: 8),
          _buildStatRow('Tiros al arco', '${stats.shotsOnTargetHome}', '${stats.shotsOnTargetAway}'),
          const SizedBox(height: 8),
          _buildStatRow('Córners', '${stats.cornersHome}', '${stats.cornersAway}'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String homeValue, String awayValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          homeValue,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        Text(
          awayValue,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildOddsSection(BuildContext context, BetProvider betProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Apuestas Rápidas',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildOddsButton(context, match.homeTeam, match.odds.homeWin, 'homeWin', betProvider),
              _buildOddsButton(context, 'Empate', match.odds.draw, 'draw', betProvider),
              _buildOddsButton(context, match.awayTeam, match.odds.awayWin, 'awayWin', betProvider),
              _buildOddsButton(context, '+2.5', match.odds.over25, 'over25', betProvider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOddsButton(
    BuildContext context,
    String selection,
    double odds,
    String betType,
    BetProvider betProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          betProvider.addToBetSlip(
            matchId: match.id,
            homeTeam: match.homeTeam,
            awayTeam: match.awayTeam,
            betType: betType,
            selection: selection,
            odds: odds,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Apuesta agregada: $selection @ ${odds.toStringAsFixed(2)}'),
              backgroundColor: const Color(0xFF22C55E),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF334155)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(selection, style: const TextStyle(fontSize: 12)),
              Text(
                '@${odds.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF22C55E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
