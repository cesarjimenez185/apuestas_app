import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/match_provider.dart';
import '../providers/bet_provider.dart';
import 'home_screen.dart';
import 'live_matches_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'bet_slip_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LiveMatchesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final matchProvider = context.read<MatchProvider>();
    await matchProvider.seedMatchesIfNeeded();
    await matchProvider.loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_soccer, color: Color(0xFF22C55E)),
            SizedBox(width: 8),
            Text(
              'BetFoot',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF22C55E),
              ),
            ),
          ],
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '\$${authProvider.user?.balance.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.live_tv),
            label: 'En Vivo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: Consumer<BetProvider>(
        builder: (context, betProvider, child) {
          if (betProvider.betSlip.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BetSlipScreen()),
              );
            },
            backgroundColor: const Color(0xFF22C55E),
            icon: const Icon(Icons.ticket),
            label: Text('Ticket (${betProvider.betSlip.length})'),
          );
        },
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
            ),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF22C55E),
                      child: Icon(Icons.person, size: 32, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      authProvider.user?.name ?? 'Usuario',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      authProvider.user?.email ?? '',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'LIGAS',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildLeagueItem('Todas', null, '🌍'),
          _buildLeagueItem('Premier League', 'Premier League', '🏴󠁧󠁢󠁥󠁮󠁧󠁿'),
          _buildLeagueItem('La Liga', 'La Liga', '🇪🇸'),
          _buildLeagueItem('Champions League', 'Champions League', '🏆'),
          _buildLeagueItem('Serie A', 'Serie A', '🇮🇹'),
          _buildLeagueItem('Bundesliga', 'Bundesliga', '🇩🇪'),
        ],
      ),
    );
  }

  Widget _buildLeagueItem(String name, String? league, String emoji) {
    return Consumer<MatchProvider>(
      builder: (context, matchProvider, child) {
        final isSelected = matchProvider.currentLeague == (league ?? 'all');
        return ListTile(
          leading: Text(emoji, style: const TextStyle(fontSize: 20)),
          title: Text(name),
          selected: isSelected,
          selectedTileColor: const Color(0xFF22C55E).withOpacity(0.1),
          onTap: () {
            matchProvider.setLeague(league ?? 'all');
            matchProvider.loadMatches();
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
