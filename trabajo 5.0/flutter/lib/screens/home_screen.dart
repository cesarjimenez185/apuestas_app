import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/match_provider.dart';
import '../providers/bet_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchProvider>(
      builder: (context, matchProvider, child) {
        return Column(
          children: [
            _buildFilterChips(context, matchProvider),
            Expanded(
              child: matchProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF22C55E),
                      ),
                    )
                  : matchProvider.matches.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: matchProvider.matches.length,
                          itemBuilder: (context, index) {
                            return MatchCard(
                              match: matchProvider.matches[index],
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips(BuildContext context, MatchProvider matchProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(context, matchProvider, 'Todos', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip(context, matchProvider, 'Próximos', 'scheduled'),
          const SizedBox(width: 8),
          _buildFilterChip(context, matchProvider, 'Finalizados', 'finished'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    MatchProvider matchProvider,
    String label,
    String value,
  ) {
    final isSelected = matchProvider.currentFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF22C55E),
      onSelected: (_) {
        matchProvider.setFilter(value);
        matchProvider.loadMatches();
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay partidos disponibles',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  final Match match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final matchProvider = context.read<MatchProvider>();
    
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
                Text(
                  match.league,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: match.isLive
                        ? Colors.red.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    match.isLive
                        ? "${match.minute}'"
                        : match.isFinished
                            ? 'Finalizado'
                            : matchProvider.formatMatchTime(match.date),
                    style: TextStyle(
                      color: match.isLive ? Colors.red : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Icon(Icons.sports_soccer, size: 32),
                      const SizedBox(height: 4),
                      Text(
                        match.homeTeam,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    match.isLive || match.isFinished
                        ? '${match.homeScore} - ${match.awayScore}'
                        : 'VS',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(Icons.sports_soccer, size: 32),
                      const SizedBox(height: 4),
                      Text(
                        match.awayTeam,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!match.isFinished) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildOddsSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOddsSection(BuildContext context) {
    final betProvider = context.read<BetProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cuotas',
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
              _buildOddsButton(
                context,
                match.homeTeam,
                match.odds.homeWin,
                'homeWin',
                betProvider,
              ),
              _buildOddsButton(
                context,
                'Empate',
                match.odds.draw,
                'draw',
                betProvider,
              ),
              _buildOddsButton(
                context,
                match.awayTeam,
                match.odds.awayWin,
                'awayWin',
                betProvider,
              ),
              _buildOddsButton(
                context,
                '+2.5',
                match.odds.over25,
                'over25',
                betProvider,
              ),
              _buildOddsButton(
                context,
                '-2.5',
                match.odds.under25,
                'under25',
                betProvider,
              ),
              _buildOddsButton(
                context,
                'Ambos',
                match.odds.bothTeamsScore,
                'bothTeamsScore',
                betProvider,
              ),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF334155)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                selection,
                style: const TextStyle(fontSize: 11),
              ),
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
