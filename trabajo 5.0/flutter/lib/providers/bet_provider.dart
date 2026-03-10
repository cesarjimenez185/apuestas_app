import 'package:flutter/material.dart';
import '../services/bet_service.dart';
import '../services/api_service.dart';

class Bet {
  final String id;
  final String matchId;
  final String betType;
  final String selection;
  final double odds;
  final double amount;
  final double potentialWin;
  final String status;
  final dynamic match;
  
  Bet({
    required this.id,
    required this.matchId,
    required this.betType,
    required this.selection,
    required this.odds,
    required this.amount,
    required this.potentialWin,
    required this.status,
    this.match,
  });
  
  factory Bet.fromJson(Map<String, dynamic> json) {
    return Bet(
      id: json['_id'] ?? json['id'] ?? '',
      matchId: json['match']?['_id'] ?? json['match'] ?? '',
      betType: json['betType'] ?? '',
      selection: json['selection'] ?? '',
      odds: (json['odds'] ?? 1.0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
      potentialWin: (json['potentialWin'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      match: json['match'],
    );
  }
}

class BetProvider extends ChangeNotifier {
  final BetService _betService;
  final ApiService _apiService;
  
  List<Bet> _bets = [];
  bool _isLoading = false;
  String? _error;
  
  BetProvider(this._betService, this._apiService);
  
  List<Bet> get bets => _bets;
  List<BetSlipItem> get betSlip => _betService.betSlip;
  double get totalOdds => _betService.totalOdds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  double calculatePotentialWin(double amount) {
    return _betService.calculatePotentialWin(amount);
  }
  
  void addToBetSlip({
    required String matchId,
    required String homeTeam,
    required String awayTeam,
    required String betType,
    required String selection,
    required double odds,
  }) {
    _betService.addBet(
      matchId: matchId,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      betType: betType,
      selection: selection,
      odds: odds,
    );
    notifyListeners();
  }
  
  void removeFromBetSlip(int index) {
    _betService.removeBet(index);
    notifyListeners();
  }
  
  void clearBetSlip() {
    _betService.clearBets();
    notifyListeners();
  }
  
  Future<bool> placeBet(double amount) async {
    if (_betService.betSlip.isEmpty) {
      _error = 'No hay apuestas en el ticket';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _betService.placeBet(amount);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> loadBetsHistory({String? status}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final data = await _betService.getBetsHistory(status: status);
      _bets = data.map((json) => Bet.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  String getBetTypeName(String betType) {
    return _betService.getBetTypeName(betType);
  }
}
