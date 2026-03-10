import 'api_service.dart';

class BetService {
  final ApiService _apiService;
  
  BetService(this._apiService);
  
  List<BetSlipItem> betSlip = [];
  
  double get totalOdds {
    if (betSlip.isEmpty) return 1.0;
    return betSlip.fold(1.0, (total, item) => total * item.odds);
  }
  
  double calculatePotentialWin(double amount) {
    return amount * totalOdds;
  }
  
  void addBet({
    required String matchId,
    required String homeTeam,
    required String awayTeam,
    required String betType,
    required String selection,
    required double odds,
  }) {
    final existingIndex = betSlip.indexWhere((b) => b.matchId == matchId);
    
    final item = BetSlipItem(
      matchId: matchId,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      betType: betType,
      selection: selection,
      odds: odds,
    );
    
    if (existingIndex >= 0) {
      betSlip[existingIndex] = item;
    } else {
      betSlip.add(item);
    }
  }
  
  void removeBet(int index) {
    if (index >= 0 && index < betSlip.length) {
      betSlip.removeAt(index);
    }
  }
  
  void clearBets() {
    betSlip.clear();
  }
  
  Future<Map<String, dynamic>> placeBet(double amount) async {
    if (betSlip.isEmpty) {
      throw Exception('No hay apuestas en el ticket');
    }
    
    final results = <Map<String, dynamic>>[];
    
    for (final item in betSlip) {
      final result = await _apiService.placeBet(
        matchId: item.matchId,
        betType: item.betType,
        selection: item.selection,
        odds: item.odds,
        amount: amount,
      );
      results.add(result);
    }
    
    clearBets();
    return {'results': results};
  }
  
  Future<List<dynamic>> getBetsHistory({String? status}) async {
    return _apiService.getUserBets(status: status);
  }
  
  String getBetTypeName(String betType) {
    const names = {
      'homeWin': 'Ganador Local',
      'draw': 'Empate',
      'awayWin': 'Ganador Visitante',
      'over25': 'Más de 2.5',
      'under25': 'Menos de 2.5',
      'bothTeamsScore': 'Ambos Marcan',
      'doubleChance1X': 'Local o Empate',
      'doubleChance12': 'No Empate',
      'doubleChanceX2': 'Visitante o Empate',
    };
    return names[betType] ?? betType;
  }
}

class BetSlipItem {
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final String betType;
  final String selection;
  final double odds;
  
  BetSlipItem({
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.betType,
    required this.selection,
    required this.odds,
  });
}
